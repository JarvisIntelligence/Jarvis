import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'ChangeNotifiers/user_chat_list_change_notifier.dart';
import 'Utilities/extras.dart';
import 'home_chat.dart';

class ArchivedChats extends StatefulWidget {
  const ArchivedChats({super.key});

  @override
  State<ArchivedChats> createState() => _ArchivedChatsState();
}

class _ArchivedChatsState extends State<ArchivedChats> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<Map<String, dynamic>> filteredList = [];
  Map<String, bool> isChatSelectedMap = {};
  int numberOfSelectedChats = 0;
  Set<String> selectedData = {};

  late Future<LottieComposition> _lottieComposition;


  @override
  void initState() {
    super.initState();
    _lottieComposition = _loadLottieComposition();
  }


  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
      filteredList = searchList(context.read<UserChatListChangeNotifier>().userArchivedChatsList, _lastWords);
    });
  }

  Future<LottieComposition> _loadLottieComposition() async {
    return await AssetLottie('assets/lottie_animations/add_friend_animation.json').load();
  }

  void startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: onSpeechResult);
    } else {
      InAppNotifications.show(
          description:
          'To use the microphone, you need to allow audio permissions for the app',
          onTap: () {}
      );
    }
    setState(() {});
  }

  void increaseDecreaseNumberOfSelectedChats(String increaseOrDecrease) {
    setState(() {
      if (increaseOrDecrease == 'increase') {
        numberOfSelectedChats++;
      } else {
        numberOfSelectedChats--;
        if (numberOfSelectedChats == 0){
          setState(() {
            selectedData = {};
          });
        }
      }
    });
  }

  void changeIsChatSelected(String id) {
    setState(() {
      isChatSelectedMap[id] = !isChatSelectedMap[id]!;
    });
  }
  Future<void> addChatToDataMap (String id) async {
    selectedData.add(id);
  }

  Future<void> removeChatFromDataMap(String id) async {
    selectedData.remove(id);
  }


  List<Map<String, dynamic>> searchList(List<Map<String, dynamic>> list, String query) {
    return list.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to UserChatListChangeNotifier changes
    var listNotifier = context.watch<UserChatListChangeNotifier>();
    var userArchivedChatsList = listNotifier.userArchivedChatsList;

    List<Map<String, dynamic>> mutableArchivedChatsList = List<Map<String, dynamic>>.from(userArchivedChatsList);
    mutableArchivedChatsList.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));

    // userArchivedChatsList.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));

    List<Widget> buildChatWidgets(List<Map<String, dynamic>> chatList) {
      List<Widget> chatWidgets = [];

      for (int index = 0; index < chatList.length; index++) {
        var entry = chatList[index];
        String encodedUserImage = Extras().encodeUrl(entry['userImage']);
        String encodedUserImage2 = Extras().encodeUrl(entry['userImage2']);
        String encodedUserImage3 = Extras().encodeUrl(entry['userImage3']);
        chatWidgets.add(
          HomeChat(
              notification: entry['notification'],
              userImage: entry['userImage'],
              userImage2: entry['userImage2'],
              userImage3: entry['userImage3'],
              numberOfUsers: entry['numberOfUsers'],
              groupImage: entry['groupImage'],
              name: entry['name'],
              userName: entry['userName'],
              lastMessage: entry['lastMessage'],
              lastMessageTime: DateTime.parse(entry['lastMessageTime']),
              isGroup: entry['isGroup'],
              conversationId: entry['conversationId'],
              participantsId: entry['participantsId'],
              isPinned: entry['isPinned'],
              isArchived: entry['isArchived'],
              increaseDecreaseNumberOfSelectedChats: increaseDecreaseNumberOfSelectedChats,
              isChatSelected: isChatSelectedMap[entry['id']] ?? false,
              changeIsChatSelected: () => changeIsChatSelected(entry['id']),
              addChatToDataMap: () => addChatToDataMap(entry['id']),
              removeChatFromDataMap: () => removeChatFromDataMap(entry['id']),
              encodedUserImage: encodedUserImage,
              encodedUserImage2: encodedUserImage2,
              encodedUserImage3: encodedUserImage3,
          ),
        );
      }
      return chatWidgets;
    }

    List<Widget> userChatsWidgets = buildChatWidgets(userArchivedChatsList);
    List<Widget> filteredListWidgets;

    if (filteredList.isEmpty) {
      filteredListWidgets = [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Lottie.asset(
                  'assets/lottie_animations/nothing_found_animation.json',
                  width: 80
              ),
              Text(
                'Search result not found',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: 'Inter',
                  fontSize: 8,
                ),
              ),
            ],
          ),
        )
      ];
    } else {
      filteredListWidgets = buildChatWidgets(filteredList);
    }


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            backHeader(),
            searchChatListBody(),
            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 1.0,
              height: 0,
            ),
            chatListBody(userChatsWidgets, filteredListWidgets),
          ],
        ),
      ),
    );
  }

  Widget chatListBody(List<Widget> userChatsWidgets, List<Widget> filteredListWidgets) {
    var listNotifier = Provider.of<UserChatListChangeNotifier>(context, listen: true);
    var userArchivedChatsList = listNotifier.userArchivedChatsList;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: SingleChildScrollView(
          child: Column(
            children: (userArchivedChatsList.isEmpty)
                ? [userChatListEmpty()]
                : userChatListNotEmpty(userChatsWidgets, filteredListWidgets),
          ),
        ),
      ),
    );
  }

  Widget userChatListEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          FutureBuilder<LottieComposition>(
            future: _lottieComposition,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading animation'));
                } else {
                  return Lottie(composition: snapshot.data, width: 80,);
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(height: 10,),
          Text('Add a friend or group to start chatting', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Inter', fontSize: 8),)
        ],
      ),
    );
  }

  List<Widget> userChatListNotEmpty(List<Widget> userChatsWidgets, List<Widget> filteredListWidgets) {
    if (_searchController.text == '') {
      return [
        ...userChatsWidgets,
        userChatEncryptionMessage(),
      ];
    } else {
      return [
        PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            setState(() {
              _searchController.text = '';
              _searchFocusNode.unfocus();
            });
          },
          child: Column(
            children: filteredListWidgets,
          ),
        ),
      ];
    }
  }

  Widget userChatEncryptionMessage() {
    return (_searchController.text == '')
        ? Padding(
      padding: const EdgeInsets.only(bottom: 50, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onPrimary, size: 15,),
          const SizedBox(width: 10,),
          Text('Your personal chats are encrypted', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Inter', fontSize: 10),)
        ],
      ),
    )
        : const SizedBox.shrink();
  }

  Widget searchChatListBody() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary,
      ),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary,),
          const SizedBox(width: 10,),
          Expanded(
            child: TextField(
              enableSuggestions: true,
              autocorrect: false,
              onChanged: (a) {
                setState(() {
                  filteredList = searchList(context.read<UserChatListChangeNotifier>().userArchivedChatsList, a);
                });
              },
              focusNode: _searchFocusNode,
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              cursorColor: Theme.of(context).colorScheme.onSecondaryContainer,
              decoration: InputDecoration(hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              ),
            ),
          ),
          IconButton(
              onPressed: () async {
                if (!_speechEnabled) {
                  await _initSpeech();
                }
                startListening();
              },
              icon: Icon(Icons.mic_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 22,)
          )
        ],
      ),
    );
  }

  Widget backHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(
                Icons.arrow_back,
                size: 20,
                color: Theme.of(context).colorScheme.scrim,
              )),
          Text(
            'Archived Chats',
            style: TextStyle(
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.scrim,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
