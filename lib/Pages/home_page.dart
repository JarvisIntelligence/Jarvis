import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/home_chat.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> userChats = [
    {
      'notification': true,
      'id': 1,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': 2,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/cody_fisher.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': 3,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Fisher',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/cody_fisher.jpg',
    },
    {
      'notification': true,
      'id': 4,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': 5,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/jenifier_lopez.jpg',
      'name': 'Jennifer Lopez',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': 6,
      'userImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'name': 'Jessica Ramirez',
      'lastMessage': "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)",
      'lastMessageTime': DateTime.parse('2023-05-24T07:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': 7,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/theresa_webb.jpg',
      'name': 'Theresa Webb',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': true,
      'id': 8,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Angela',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/dianne_russell.jpg',
    },
    {
      'notification': true,
      'id': 9,
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Theresa',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T22:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/theresa_webb.jpg',
    }
  ];

  // Searches the user chats for the person's name typed
  List<Map<String, dynamic>> searchList(List<Map<String, dynamic>> list, String query) {
    return list.where((item) => item['name'].contains(query)).toList();
  }

  /// This has to happen only once per app
  _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
      filteredList = searchList(userChats, _lastWords);
    });
  }

  void startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: onSpeechResult);
    } else {
      InAppNotifications.show(
          description:
          'To use the microphone, you need to allow audio permissions for the app',
          onTap: () {
          }
        );
      }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Sort userChats by lastMessageTime in descending order
    userChats.sort((a, b) => a['lastMessageTime'].compareTo(b['lastMessageTime']));

    List <Widget> userChatsWidgets = userChats.map((entry) => HomeChat(
        notification: entry['notification'],
        userImage: entry['userImage'],
        userImage2: entry['userImage2'],
        name: entry['name'],
        lastMessage: entry['lastMessage'],
        lastMessageTime: entry['lastMessageTime'],
        isGroup: entry['isGroup']
    )).toList();
    List <Widget> filteredListWidgets = filteredList.map((entry) => HomeChat(
        notification: entry['notification'],
        userImage: entry['userImage'],
        userImage2: entry['userImage2'],
        name: entry['name'],
        lastMessage: entry['lastMessage'],
        lastMessageTime: entry['lastMessageTime'],
        isGroup: entry['isGroup']
    )).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF202325),
      body: Column(
        children: [
          Container(
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
                              padding: const EdgeInsets.all(10), // Background color
                            ),
                            child: const Icon(Icons.person_add_alt_outlined, color: Color(0xFFC9F0FF), size: 20,),
                          ),
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
                              padding: const EdgeInsets.all(10), // Background color
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
                  Container(
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
                            onChanged: (a) {
                              setState(() {
                                filteredList = searchList(userChats, a);
                              });
                            },
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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 10, top: 15, bottom: 15),
                    child: GestureDetector(
                        onTap: () {
                          context.go('/homepage/chat/JARVIS AI/false/a/a');
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
                                    )                                  ],
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
                  ),//AI Chat
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: (_searchController.text == '') ? userChatsWidgets : filteredListWidgets
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50, top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: Color(0xFFCDCFD0), size: 15,),
                        SizedBox(width: 10,),
                        Text('Your personal chats are encrypted', style: TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 10),)
                      ],
                    ),
                  ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
