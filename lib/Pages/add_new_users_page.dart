import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/recent_list_chat.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';

import '../Components/cache_image.dart';

class AddNewUsersPage extends StatefulWidget {
  const AddNewUsersPage({super.key});

  @override
  State<AddNewUsersPage> createState() => _AddNewUsersPageState();
}

class _AddNewUsersPageState extends State<AddNewUsersPage> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _groupNameController = TextEditingController();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isAddingGroup = false;
  String newGroupName = 'Group Name';
  bool editGroupName = false;
  double groupNameInputWidth = 90.0;

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
      'groupImage': '',
      'id': '1'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'userImage2': '',
      'name': 'Maria Garcia',
      'groupImage': '',
      'id': '2'
    },
    {
      'userImage3': '',
      'numberOfUsers': "2",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/65.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/44.jpg',
      'name': 'James & Maria',
      'groupImage': '',
      'id': '3'
    },
    {
      'userImage3': 'https://randomuser.me/api/portraits/men/56.jpg',
      'numberOfUsers': "3",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/women/68.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/men/36.jpg',
      'name': 'Project Team',
      'groupImage': '',
      'id': '4'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/men/12.jpg',
      'userImage2': '',
      'name': 'Robert Brown',
      'groupImage': '',
      'id': '5'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/15.jpg',
      'userImage2': '',
      'name': 'Linda Davis',
      'groupImage': '',
      'id': '6'
    },
    {
      'userImage3': 'https://randomuser.me/api/portraits/women/45.jpg',
      'numberOfUsers': "3",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/18.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/19.jpg',
      'name': 'Marketing Team',
      'groupImage': 'https://picsum.photos/150',
      'id': '7'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/23.jpg',
      'userImage2': '',
      'name': 'Barbara Martinez',
      'groupImage': '',
      'id': '8'
    },
    {
      'userImage3': '',
      'numberOfUsers': "2",
      'isGroup': true,
      'userImage': 'https://randomuser.me/api/portraits/men/24.jpg',
      'userImage2': 'https://randomuser.me/api/portraits/women/42.jpg',
      'name': 'Paul & Susan',
      'groupImage': 'https://picsum.photos/150',
      'id': '9'
    },
    {
      'userImage3': '',
      'numberOfUsers': "1",
      'isGroup': false,
      'userImage': 'https://randomuser.me/api/portraits/women/42.jpg',
      'userImage2': '',
      'name': 'Susan Taylor',
      'groupImage': '',
      'id': '10'
    }
  ];
  // List<Map<String, dynamic>> userRecentsList = [];
  List<Map<String, dynamic>> filteredUserRecentsList = [];
  List<Map<String, dynamic>> previousUserRecentsList = [];
  List<Map<String, dynamic>> newGroupUserList = [];
  // Map to track user add selection state of each user in a new group
  Map<int, bool> isUserSelectedMap = {};

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {setState(() {});});
    _groupNameController.addListener(updateGroupNameInputWidth);
    _updateUserSelectionState();
  }

  @override
  void dispose() {
    _groupNameController.removeListener(updateGroupNameInputWidth);
    _searchFocusNode.removeListener(() {setState(() {});});
    _searchFocusNode.dispose();
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _updateUserSelectionState() {
    int index = 0;
    setState(() {
      isUserSelectedMap = {};
    });
    for (var userChatMaps in userRecentsList) {
      isUserSelectedMap[index++] = false;
    }
  }

  void changeIsUserSelected(int index) {
    setState(() {
      isUserSelectedMap[index] = !isUserSelectedMap[index]!;
    });
  }

  void addingUsersToNewGroup(String name, String profileImage, int userIndex) {
    Map<String, dynamic> newUser = {
      'name': name,
      'profileImage': profileImage,
      'userIndex': userIndex
    };
    setState(() {
      newGroupUserList.add(newUser);
    });
  }

  void updateGroupNameInputWidth() {
    final text = newGroupName;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(
        fontSize: 14.0,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600
      )),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    setState(() {
      groupNameInputWidth = textPainter.size.width;
    });
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
      filteredUserRecentsList = searchList(userRecentsList, _lastWords);
    });
  }

  // Searches the user chats for the person's name typed
  List<Map<String, dynamic>> searchList(List<Map<String, dynamic>> list, String query) {
    return list.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).toList();
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
    // Create a deep copy of userRecentsList
    previousUserRecentsList = List<Map<String, dynamic>>.from(
        userRecentsList.map((user) => Map<String, dynamic>.from(user))
    );

    setState(() {
      userRecentsList.removeWhere((user) => user['isGroup'] == true);
      _updateUserSelectionState();
    });
  }

  void resetGroupSelection() {
    setState(() {
      isAddingGroup = !isAddingGroup;
      userRecentsList = previousUserRecentsList;
      newGroupUserList = [];
      newGroupName = 'Group Name';
    });
    _controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut
    );
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
              SizedBox(
                height: (_currentPageIndex == 0) ? 120 : 210,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPageIndex = page;
                    });
                  },
                  children: [
                    addButtons(),
                    addingUsersToGroup()
                  ],
                ),
              ),
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
                  setState(() {
                    filteredUserRecentsList = searchList(userRecentsList, a);
                  });
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
    List<Widget> userRecentsListWidgets = userRecentsList.asMap().entries.map((entry) {
      int userIndex = entry.key;
      var entryValue =  entry.value;
      return RecentListChat(
        isGroup: entryValue['isGroup'],
        userImage: entryValue['userImage'],
        userImage2: entryValue['userImage2'],
        userImage3: entryValue['userImage3'],
        numberOfUsers: entryValue['numberOfUsers'],
        name: entryValue['name'],
        groupImage: entryValue['groupImage'],
        isAddingGroup: isAddingGroup,
        addingUsersToNewGroup: addingUsersToNewGroup,
        isUserSelected: isUserSelectedMap[userIndex] ?? false,
        changeIsUserSelected: () => changeIsUserSelected(userIndex),
        userIndex: userIndex,
        id: entryValue['id'],
      );
    }).toList();

    List<Widget> filteredUserRecentsListWidgets = filteredUserRecentsList.asMap().entries.map((entry) {
      int userIndex = entry.key;
      var entryValue =  entry.value;
      return RecentListChat(
          isGroup: entryValue['isGroup'],
          userImage: entryValue['userImage'],
          userImage2: entryValue['userImage2'],
          userImage3: entryValue['userImage3'],
          numberOfUsers: entryValue['numberOfUsers'],
          name: entryValue['name'],
          groupImage: entryValue['groupImage'],
          isAddingGroup: isAddingGroup,
          addingUsersToNewGroup: addingUsersToNewGroup,
          isUserSelected: isUserSelectedMap[userIndex] ?? false,
          changeIsUserSelected: () => changeIsUserSelected(userIndex),
          userIndex: userIndex,
          id: entryValue['id'],
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(left: 5, top: (_currentPageIndex == 0) ? 20 : 0, bottom: 10),
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
            child: (userRecentsList.isEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie_animations/nothing_found_animation.json', width: 80),
                        Text((_searchFocusNode.hasFocus) ? 'Search result not found' : 'You have no recent chats', style: const TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 8),)
                      ],
                    ),
                  )
                : SingleChildScrollView(
              child: Column(
                children: (_searchController.text == '') ? userRecentsListWidgets : filteredUserRecentsListWidgets,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget addingUsersToGroup() {
    List<Widget> newGroupUserListWidgets = newGroupUserList.map((entry) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 30),
            child: Column(
              children: [
                CacheImage(
                    imageUrl: entry['profileImage'], // Change this to the third user's image URL
                    isGroup: false,
                    numberOfUsers: '1'
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 70,
                  child: Text(entry['name'],
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),),
                )
              ],
            ),
          ),
          Positioned(
              top: 25,
              right: 20,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF303437),
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        newGroupUserList.removeWhere((user) => user['name'] == entry['name']);
                        changeIsUserSelected(entry['userIndex']);
                      });
                    },
                    icon: const Icon(Icons.close, size: 5, color: Colors.white,),
                  ),
                ),
              )
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    (editGroupName)
                        ? ConstrainedBox(
                      constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 150// Set your desired minimum width here
                      ),
                      child: SizedBox(
                        width: groupNameInputWidth,
                        height: 20,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '',
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600
                            ),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent, width: 0),
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              newGroupName = text;
                            });
                          },
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: _groupNameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                        : ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: 150
                      ),
                      child: Text((newGroupName.isNotEmpty) ? newGroupName : 'GroupName',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600
                        ),),
                    ),
                    const SizedBox(width: 10,),
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: IconButton(
                          onPressed: (){
                            setState(() {
                              editGroupName = !editGroupName;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF6B4EFF)),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.create, color: Colors.white, size: 10,)
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 25,
                  height: 25,
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          resetGroupSelection();
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF6C7072)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.close, color: Colors.white, size: 10,)
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: newGroupUserListWidgets,
              ),
            )
          ),
          const SizedBox(height: 20,),
          Visibility(
            visible: (newGroupUserListWidgets.isNotEmpty) ? true : false,
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 45,
                height: 35,
                child: IconButton(
                    onPressed: (){},
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.check, color: Colors.white, size: 15,)
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
