import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/recent_list_chat.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';

class AddNewUsersPage extends StatefulWidget {
  const AddNewUsersPage({super.key});

  @override
  State<AddNewUsersPage> createState() => _AddNewUsersPageState();
}

class _AddNewUsersPageState extends State<AddNewUsersPage> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isAddingGroup = false;

  int _currentPageIndex = 0;
  final _controller = PageController(
      initialPage: 0
  );

  List<Map<String, dynamic>> userRecentsList = [
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'userImage2': '',
      'name': 'Stephen Reed',
      'groupImage': ''
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'userImage2': '',
      'name': 'Maria Garcia',
      'groupImage': ''
    },
    {
      'userImage3': '',
      'numberOfUsers': "2",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/65.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/44.jpg',
      'name': 'James & Maria',
      'groupImage': ''
    },
    {
      'userImage3': 'https://randomuser.me/api/portraits/men/56.jpg',
      'numberOfUsers': "3",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/women/68.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/men/36.jpg',
      'name': 'Project Team',
      'groupImage': ''
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/men/12.jpg',
      'userImage2': '',
      'name': 'Robert Brown',
      'groupImage': ''
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/15.jpg',
      'userImage2': '',
      'name': 'Linda Davis',
      'groupImage': ''
    },
    {
      'userImage3': 'https://randomuser.me/api/portraits/women/45.jpg',
      'numberOfUsers': "3",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/18.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/19.jpg',
      'name': 'Marketing Team',
      'groupImage': 'https://picsum.photos/150'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/23.jpg',
      'userImage2': '',
      'name': 'Barbara Martinez',
      'groupImage': ''
    },
    {
      'userImage3': '',
      'numberOfUsers': "2",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/24.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/42.jpg',
      'name': 'Paul & Susan',
      'groupImage': 'https://picsum.photos/150'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/42.jpg',
      'userImage2': '',
      'name': 'Susan Taylor',
      'groupImage': ''
    }
  ];


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
      // filteredList = searchList(userChatList, _lastWords);
    });
  }

  void startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: onSpeechResult);
    } else {
      InAppNotifications.show(
          description:
          'To use the microphone, you need to allow audio permissions for the app',
          onTap: () {});
    }
    setState(() {});
  }

  void sortUserRecentsList() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF202325),
        body: Padding(
          padding: const EdgeInsets.only(left: 5, top: 50),
          child: Column(
            children: [
              backHeader(),
              const SizedBox(
                height: 20,
              ),
              searchChatListBody(),
              addButtons(),
              // PageView(
              //   scrollDirection: Axis.horizontal,
              //   controller: _controller,
              //   physics: const NeverScrollableScrollPhysics(),
              //   onPageChanged: (int page) {
              //     setState(() {
              //       _currentPageIndex = page;
              //     });
              //   },
              //   children: [
              //     addButtons(),
              //     aadingUsersToGroup()
              //   ],
              // ),
              Expanded(child: recentChatList())
            ],
          ),
        ));
  }

  Widget backHeader() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.white,
            )),
        const Text(
          'Contacts',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget searchChatListBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 20),
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF6C7072),
        ),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.search,
              color: Color(0xFFCDCFD0),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (a) {
                  // setState(() {
                  //   filteredList = searchList(userChatList, a);
                  // });
                },
                focusNode: _searchFocusNode,
                controller: _searchController,
                style: const TextStyle(
                    color: Color(0xFFE7E7FF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400),
                cursorColor: const Color(0xFF979C9E),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Color(0xFF979C9E),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400),
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
                icon: const Icon(
                  Icons.mic_rounded,
                  color: Color(0xFFCDCFD0),
                  size: 22,
                ))
          ],
        ),
      ),
    );
  }

  Widget addButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Background color
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6B4EFF), // Set the border color
                      width: 2.0, // Set the border width
                    ),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_outlined,
                    color: Color(0xFFC9F0FF),
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const Text(
                  'Add New Contact',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter'),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isAddingGroup = !isAddingGroup;
              });
              sortUserRecentsList();
              _controller.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Background color
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6B4EFF), // Set the border color
                      width: 2.0, // Set the border width
                    ),
                  ),
                  child: const Icon(
                    Icons.group_add_outlined,
                    color: Color(0xFFC9F0FF),
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const Text(
                  'Add New Group',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget recentChatList() {
    List<Widget> userRecentsListWidgets = userRecentsList.map((entry) {
      return RecentListChat(
        isGroup: entry['isGroup'],
        userImage: entry['userImage'],
        userImage2: entry['userImage2'],
        userImage3: entry['userImage3'],
        numberOfUsers: entry['numberOfUsers'],
        name: entry['name'],
        groupImage: entry['groupImage'],
        isAddingGroup: isAddingGroup
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 20, bottom: 10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recents',
                style: TextStyle(
                    color: Color(0xFFE3E5E5),
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 21, top: 5),
            child: Container(
              color: const Color(0xFF6C7072),
              height: 1,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: userRecentsListWidgets,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget addingUsersToGroup() {
    return const Placeholder();
  }
}
