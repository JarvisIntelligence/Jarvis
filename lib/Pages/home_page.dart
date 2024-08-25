import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/home_chat.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lottie/lottie.dart';

import '../Components/ChangeNotifiers/user_chat_list_change_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool archivedNotification = true;
  String _lastWords = '';
  List<Map<String, dynamic>> filteredList = [];
  bool showChatSelectedOptions = false;

  late Future<LottieComposition> _lottieComposition;

  @override
  void initState() {
    super.initState();
    _lottieComposition = _loadLottieComposition();
    init();
  }

  Future<void> init() async {
    // Initial load from secure storage
    final listNotifier = Provider.of<UserChatListChangeNotifier>(context, listen: false);
    await listNotifier.loadInitialData();
  }

  Future<LottieComposition> _loadLottieComposition() async {
    return await AssetLottie('assets/lottie_animations/add_friend_animation.json').load();
  }

  // Searches the user chats for the person's name typed
  List<Map<String, dynamic>> searchList(List<Map<String, dynamic>> list, String query) {
    return list.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  /// This has to happen only once per app
  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
      filteredList = searchList(context.read<UserChatListChangeNotifier>().userChatList, _lastWords);
    });
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

  void toggleShowChatSelectedOptions() {
    setState(() {
      showChatSelectedOptions = !showChatSelectedOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to UserChatListChangeNotifier changes
    var listNotifier = context.watch<UserChatListChangeNotifier>();
    var userChatList = listNotifier.userChatList;

    // Sort userChats by lastMessageTime in descending order
    userChatList.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));

    List<Widget> buildChatWidgets(List<Map<String, dynamic>> chatList) {
      return chatList.map((entry) => HomeChat(
        notification: entry['notification'],
        userImage: entry['userImage'],
        userImage2: entry['userImage2'],
        userImage3: entry['userImage3'],
        numberOfUsers: entry['numberOfUsers'],
        groupImage: entry['groupImage'],
        name: entry['name'],
        lastMessage: entry['lastMessage'],
        lastMessageTime: DateTime.parse(entry['lastMessageTime']),
        isGroup: entry['isGroup'],
        id: entry['id'],
        toggleShowChatSelectedOptions: toggleShowChatSelectedOptions,
      )).toList();
    }

    List<Widget> userChatsWidgets = buildChatWidgets(userChatList);
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
      body: Stack(
        children: [
          Column(
            children: [
              chatListHeader(),
              chatListBody(userChatsWidgets, filteredListWidgets),
            ],
          ),
          chatSelectedOptions(),
          addChatButton(),
        ],
      ),
    );
  }


  Widget chatListHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF5538EE),
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_name.svg',
                  height: 25,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.scrim,
                    BlendMode.srcIn,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        context.go('/homepage/myprofile');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0, // border width
                          ),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFFC9F0FF), size: 20,),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: (){
                        context.go('/homepage/usersettings');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0, // border width
                          ),
                        ),
                        child: const Icon(Icons.settings, color: Color(0xFFC9F0FF), size: 20,),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            searchChatListBody(),
            const SizedBox(
              height: 10,
            ),
            aiChatBody() //AI Chat
          ],
        ),
      ),
    );
  }

  Widget aiChatBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 10, top: 15, bottom: 15),
      child: GestureDetector(
          onTap: () {
            context.go('/homepage/chat/JARVIS AI/false/a/a/0/a/1');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ai_logo.svg',
                    height: 45,
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JARVIS AI', style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                        child: Text("Ask AI anything",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/icons/ai_icon.svg',
                height: 30,
              )
            ],
          )
      ),
    );
  }

  Widget searchChatListBody() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
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
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (a) {
                setState(() {
                  filteredList = searchList(context.read<UserChatListChangeNotifier>().userChatList, a);
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

  Widget chatListBody(List<Widget> userChatsWidgets, List<Widget> filteredListWidgets) {
    var listNotifier = Provider.of<UserChatListChangeNotifier>(context, listen: true);
    var userChatList = listNotifier.userChatList;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: (userChatList.isEmpty)
              ? [userChatListEmpty()]
              : userChatListNotEmpty(userChatsWidgets, filteredListWidgets),
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
        archivedChat(),
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

  Widget addChatButton() {
    return Positioned(
      bottom: 50,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          context.go('/homepage/addnewusers');
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
          fixedSize: WidgetStateProperty.all(const Size(50, 50)), // Set the exact size for a circular button
          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiary),
        ),
        child: const Icon(Icons.add, size: 14, color: Color(0xFFC9F0FF)),
      ),
    );
  }

  Widget chatSelectedOptions() {
    return Visibility(
        visible: showChatSelectedOptions,
        child: Positioned(
          bottom: 120,
          right: 32,
            child: Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(5), // Curved edges
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {

                    },
                    child: Icon(Icons.archive_outlined, size: 12, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                  ), // copy
                  const SizedBox(height: 20,),
                  GestureDetector(
                      onTap: (){},
                      child: Image.asset('assets/icons/push_pin_icon.svg', width: 14, color: Theme.of(context).colorScheme.onSecondaryContainer,)
                  ), // pin
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Icon(Icons.delete_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ), //delete
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Icon(Icons.notifications_off_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ), //notifications
                ],
              ),
            )
        )
    );
  }

  Widget archivedChat() {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: GestureDetector(
          onTap: () {
            context.push('/homepage/archivedchats');
          },
          child: Container(
            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 15),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1
                    )
                )
            ),
            child: Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 11, // Adjust as needed
                          height: 11, // Adjust as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (archivedNotification) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surface, // Change color as needed
                          ),
                        ),
                        const SizedBox(width: 10,),
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(Icons.archive_outlined, size: 30,),
                          ),
                        ),
                        const SizedBox(width: 15,),
                        Text('Archived Chats', style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}

