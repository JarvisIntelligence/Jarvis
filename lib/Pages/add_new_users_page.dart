import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/recent_list_chat.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Components/cache_image.dart';

class AddNewUsersPage extends StatefulWidget {
  const AddNewUsersPage({super.key});

  @override
  State<AddNewUsersPage> createState() => _AddNewUsersPageState();
}

class _AddNewUsersPageState extends State<AddNewUsersPage> {
  final storage = const FlutterSecureStorage();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _groupNameFocusNode = FocusNode();
  final FocusNode _newContactFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _groupNameController = TextEditingController();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isAddingGroup = false;
  String newGroupName = 'Group Name';
  bool editGroupName = false;
  double groupNameInputWidth = 90.0;

  int _currentPageIndex = 1;
  final _controller = PageController(
      initialPage: 1
  );

  // List<Map<String, dynamic>> userContactList = [
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
  //     'userImage2': '',
  //     'name': 'Stephen Reed',
  //     'groupImage': '',
  //     'id': '1'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
  //     'userImage2': '',
  //     'name': 'Maria Garcia',
  //     'groupImage': '',
  //     'id': '2'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/65.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/44.jpg',
  //     'name': 'James & Maria',
  //     'groupImage': '',
  //     'id': '3'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/men/56.jpg',
  //     'numberOfUsers': "3",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/68.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/36.jpg',
  //     'name': 'Project Team',
  //     'groupImage': '',
  //     'id': '4'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/12.jpg',
  //     'userImage2': '',
  //     'name': 'Robert Brown',
  //     'groupImage': '',
  //     'id': '5'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/15.jpg',
  //     'userImage2': '',
  //     'name': 'Linda Davis',
  //     'groupImage': '',
  //     'id': '6'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/women/45.jpg',
  //     'numberOfUsers': "3",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/18.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/19.jpg',
  //     'name': 'Marketing Team',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '7'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/23.jpg',
  //     'userImage2': '',
  //     'name': 'Barbara Martinez',
  //     'groupImage': '',
  //     'id': '8'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/24.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/42.jpg',
  //     'name': 'Paul & Susan',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '9'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/42.jpg',
  //     'userImage2': '',
  //     'name': 'Susan Taylor',
  //     'groupImage': '',
  //     'id': '10'
  //   }
  // ];
  List<Map<String, dynamic>> userContactList = [];
  List<Map<String, dynamic>> filteredUserRecentsList = [];
  List<Map<String, dynamic>> previousUserRecentsList = [];
  List<Map<String, dynamic>> newGroupUserList = [];

  // Map to track user add selection state of each user in a new group
  Map<int, bool> isUserSelectedMap = {};

  @override
  void initState() {
    super.initState();
    readContactListFromStorage();
    _searchFocusNode.addListener(() {setState(() {});});
    _groupNameController.addListener(updateGroupNameInputWidth);
    _updateUserSelectionState();
  }

  @override
  void dispose() {
    _groupNameController.removeListener(updateGroupNameInputWidth);
    _searchFocusNode.removeListener(() {setState(() {});});
    _searchFocusNode.dispose();
    _groupNameFocusNode.dispose();
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> readContactListFromStorage() async {
    final String? storedContactListJson = await storage.read(key: 'contactList');

    if (storedContactListJson != null) {
      final List<dynamic> decodedList = jsonDecode(storedContactListJson);
      final List<Map<String, dynamic>> contactList = decodedList.cast<Map<String, dynamic>>();
      setState(() {
        userContactList = contactList;
      });
    } else {
      setState(() {
        userContactList = [];
      });
    }
  }

  Future<void> saveContactListToStorage(List<Map<String, dynamic>> userContactList) async {
    final String jsonString = jsonEncode(userContactList);
    await storage.write(key: 'contactList', value: jsonString);
  }

  void _updateUserSelectionState() {
    int index = 0;
    setState(() {
      isUserSelectedMap = {};
    });
    for (var userChatMaps in userContactList) {
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

  void addToContactList(String userName) {
    final bool userExists = userContactList.any((contact) => contact['name'] == userName);
    if (userExists) {
      InAppNotifications.show(
        description: "User already exists in your contact list",
        onTap: (){}
      );
      return;
    }
    final List<Map<String, dynamic>> copyUserContactList = [...userContactList];
    copyUserContactList.add(
        {
          'userImage3': '',
          'numberOfUsers': "1",
          'isGroup': false,
          'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
          'userImage2': '',
          'name': userName,
          'groupImage': '',
          'id': '1'
        },
    );
    setState(() {
      userContactList = copyUserContactList;
    });
    saveContactListToStorage(userContactList);
    resetContactSelection();
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
      filteredUserRecentsList = searchList(userContactList, _lastWords);
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
    // Create a deep copy of userContactList
    previousUserRecentsList = List<Map<String, dynamic>>.from(
        userContactList.map((user) => Map<String, dynamic>.from(user))
    );

    setState(() {
      userContactList.removeWhere((user) => user['isGroup'] == true);
      _updateUserSelectionState();
    });
  }

  void resetGroupSelection() {
    setState(() {
      isAddingGroup = !isAddingGroup;
      userContactList = previousUserRecentsList;
      newGroupUserList = [];
      newGroupName = 'Group Name';
    });
    _controller.jumpToPage(
        1
    );
  }

  void resetContactSelection() {
    _usernameController.text = '';
    _controller.jumpToPage(1);
    _newContactFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                height: (_currentPageIndex == 1) ? 120 : (_currentPageIndex == 2) ? 245 : 200,
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
                    SingleChildScrollView(
                      child: addingNewUser(),
                    ),
                    addButtons(),
                    addingUsersToGroup()
                  ],
                ),
              ),
              Expanded(child: contactList())
            ],
          ),
        )
    );
  }

  Widget backHeader() {
    return Row(
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
          'Contacts',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
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
          color: Theme.of(context).colorScheme.primary,
        ),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onPrimary,
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
                    filteredUserRecentsList = searchList(userContactList, a);
                  });
                },
                focusNode: _searchFocusNode,
                controller: _searchController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400),
                cursorColor: Theme.of(context).colorScheme.onSecondaryContainer,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                icon: Icon(
                  Icons.mic_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
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
            onTap: () {
              _controller.jumpToPage(
                  0,
              );
              _newContactFocusNode.requestFocus();
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Background color
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary, // Set the border color
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
                Text(
                  'Add New Contact',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.scrim,
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
              if (userContactList.isNotEmpty) {
                setState(() {
                  isAddingGroup = !isAddingGroup;
                });
                sortUserRecentsList();
                _controller.jumpToPage(
                    2,
                );
              } else {
                InAppNotifications.show(
                  description: "Cannot create a group with an empty contact list. Add a few friend first",
                  onTap: () {}
                );
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Background color
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary, // Set the border color
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
                Text(
                  'Create New Group',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.scrim,
                      fontFamily: 'Inter'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget contactList() {
    List<Widget> userContactListWidgets = userContactList.asMap().entries.map((entry) {
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
      padding: EdgeInsets.only(left: 5, top: (_currentPageIndex == 1) ? 20 : 0, bottom: 10),
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: Row(
          //       children: [
          //         GestureDetector(
          //           onTap: () {
          //           },
          //           child: Container(
          //             width: 60,
          //             padding: const EdgeInsets.symmetric(vertical: 5.0),
          //             decoration: BoxDecoration(
          //               color: Theme.of(context).colorScheme.tertiary, // Background color
          //               borderRadius: BorderRadius.circular(12), // Curved edges
          //             ),
          //             child: Center(
          //               child: Text(
          //                 'Recents',
          //                 style: TextStyle(
          //                     color: Theme.of(context).colorScheme.tertiaryContainer,
          //                     fontFamily: 'Inter',
          //                     fontSize: 10,
          //                     fontWeight: FontWeight.w400),
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(
          //           width: 15,
          //         ),
          //         GestureDetector(
          //           onTap: () {
          //           },
          //           child: Container(
          //             width: 40,
          //             padding: const EdgeInsets.symmetric(vertical: 5.0),
          //             decoration: BoxDecoration(
          //               color: Theme.of(context).colorScheme.primary, // Background color
          //               borderRadius: BorderRadius.circular(12), // Curved edges
          //             ),
          //             child: Center(
          //               child: Text(
          //                 'All',
          //                 style: TextStyle(
          //                     color: Theme.of(context).colorScheme.onSecondaryContainer,
          //                     fontFamily: 'Inter',
          //                     fontSize: 10,
          //                     fontWeight: FontWeight.w400),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     )
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 21, top: 0),
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              height: 1,
            ),
          ),
          Expanded(
            child: (userContactList.isEmpty)
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          (_searchFocusNode.hasFocus) ? Lottie.asset('assets/lottie_animations/nothing_found_animation.json', width: 80) : Lottie.asset('assets/lottie_animations/no_contact_animation.json', width: 80),
                          // FutureBuilder<LottieComposition>(
                          //   future: _lottieComposition,
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState == ConnectionState.done) {
                          //       if (snapshot.hasError) {
                          //         return const Center(child: Text('Error loading animation'));
                          //       } else {
                          //         return Lottie(composition: snapshot.data, width: 80,);
                          //       }
                          //     } else {
                          //       return const Center(child: CircularProgressIndicator());
                          //     }
                          //   },
                          // ),
                          Text((_searchFocusNode.hasFocus) ? 'Search result not found' : 'You have no saved friends or groups', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Inter', fontSize: 8),)
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
              child: Column(
                children: (_searchController.text == '') ? userContactListWidgets : filteredUserRecentsListWidgets,
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
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.scrim,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        newGroupUserList.removeWhere((user) => user['name'] == entry['name']);
                        changeIsUserSelected(entry['userIndex']);
                      });
                    },
                    icon: Icon(Icons.close, size: 5, color: Theme.of(context).colorScheme.scrim,),
                  ),
                ),
              )
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 20, left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  (editGroupName)
                      ? ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: 100,
                        maxWidth: 150// Set your desired minimum width here
                    ),
                    child: SizedBox(
                        width: groupNameInputWidth,
                        height: 45,
                        child: Center(
                          child: TextField(
                            focusNode: _groupNameFocusNode,
                            decoration: InputDecoration(
                              labelText: '',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.scrim,
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                              ),
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0,
                                ),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.scrim,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                    ),
                  )
                      : ConstrainedBox(
                      constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 150,
                          minHeight: 45
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text((newGroupName.isNotEmpty) ? newGroupName : 'GroupName',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.scrim,
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),),
                      )
                  ),
                  (editGroupName) ? const SizedBox(width: 10) : const SizedBox.shrink(),
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: IconButton(
                        onPressed: (){
                          setState(() {
                            editGroupName = !editGroupName;
                          });
                          _groupNameFocusNode.requestFocus();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiary),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                            ),
                          ),
                        ),
                        icon: Icon(Icons.create, color: Theme.of(context).colorScheme.scrim, size: 10,)
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
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary,),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.scrim, size: 10,)
                ),
              )
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: newGroupUserListWidgets,
            ),
          ),
          const SizedBox(height: 20,),
          Visibility(
              visible: (newGroupUserListWidgets.isNotEmpty) ? true : false,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  minimumSize: const Size(double.infinity, 35),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }

  Widget addingNewUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 20, left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add New Contact', style:  TextStyle(
                  fontFamily: 'Inter',
                  color: Theme.of(context).colorScheme.scrim,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),),
              SizedBox(
                width: 25,
                height: 25,
                child: IconButton(
                    onPressed: (){
                      resetContactSelection();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary,),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.scrim, size: 10,)
                ),
              )
            ],
          ),
          newContactFields(),
          const SizedBox(height: 10,),
          Visibility(
              visible: true,
              child: TextButton(
                onPressed: () {
                  if(_usernameController.text.isNotEmpty){
                    addToContactList(_usernameController.text);
                  } else{
                    InAppNotifications.show(
                      description: 'Username field is empty',
                      onTap: () {}
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  minimumSize: const Size(double.infinity, 35),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
          )
        ],
      )
    );
  }

  Widget newContactFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(controller: _usernameController, labelText: 'Username', obscureText: false, hintText: 'Add using their username', focusNode: _newContactFocusNode,),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}
