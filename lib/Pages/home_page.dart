import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/home_chat.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';
import 'package:lottie/lottie.dart';

import '../Components/Utilities/user_chat_list_change_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<Map<String, dynamic>> filteredList = [];

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

  @override
  Widget build(BuildContext context) {
    // Use Provider.of to listen to changes and rebuild the UI
    var listNotifier = Provider.of<UserChatListChangeNotifier>(context, listen: true);
    var userChatList = listNotifier.userChatList;

    // Sort userChats by lastMessageTime in descending order
    userChatList.sort((a, b) => a['lastMessageTime'].compareTo(b['lastMessageTime']));
    List<Widget> filteredListWidgets;

    List<Widget> userChatsWidgets = userChatList.map((entry) => HomeChat(
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
        id: entry['id']
    )).toList();

    if (filteredList.isEmpty) {
      filteredListWidgets = [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Lottie.asset('assets/lottie_animations/nothing_found_animation.json', width: 80),
              const Text('Search result not found', style: TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 8),)
            ],
          ),
        )
      ];
    } else {
      filteredListWidgets = filteredList.map((entry) => HomeChat(
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
      )).toList();
    }

    return Scaffold(
        backgroundColor: const Color(0xFF202325),
        body: Stack(
          children: [
            Column(
              children: [
                chatListHeader(),
                chatListBody(userChatsWidgets, filteredListWidgets),
              ],
            ),
            addChatButton(),
            // signOutButton()
          ],
        )
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
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(
                          side: BorderSide(
                              color: Color(0xFF6B4EFF),
                              width: 2
                          ),
                        ),
                        backgroundColor: const Color(0xFF303437),
                        padding: const EdgeInsets.all(5), // Background color
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFFC9F0FF), size: 20,),
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
                      const Text('JARVIS AI', style: TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                        child: const Text("Ask AI anything",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Color(0xFFCDCFD0), fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
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
        color: const Color(0xFF6C7072),
      ),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.search, color: Color(0xFFCDCFD0),),
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
              style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              cursorColor: const Color(0xFF979C9E),
              decoration: const InputDecoration(hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF979C9E), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
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
              icon: const Icon(Icons.mic_rounded, color: Color(0xFFCDCFD0), size: 22,)
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
          const Text('Add a friend or group to start chatting', style: TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 8),)
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
        ? const Padding(
      padding: EdgeInsets.only(bottom: 50, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Color(0xFFCDCFD0), size: 15,),
          SizedBox(width: 10,),
          Text('Your personal chats are encrypted', style: TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 10),)
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
          backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF6B4EFF)),
        ),
        child: const Icon(Icons.add, size: 14, color: Color(0xFFC9F0FF)),
      ),
    );
  }

  Widget signOutButton() {
    return Positioned(
        bottom: 50,
        left: 20,
        child: ElevatedButton(
            onPressed: () async {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'user_data');
              InAppNotifications.show(
                  description:
                  'Account logged out successfully',
                  onTap: () {}
              );
              if (mounted) {
                context.go('/login');
              }
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Adjust the radius as per your requirement
                ),
              ),
              fixedSize: WidgetStateProperty.all(const Size(10, 60)), // Set the exact size
              backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
            ),
            child: const Icon(Icons.logout, size: 15, color: Color(0xFFC9F0FF),)
        )
    );
  }
}

