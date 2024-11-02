import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/send_receive_messages.dart';
import 'package:jarvis_app/Components/Utilities/SqfliteHelperClasses/chat_list_database_helper.dart';
import 'package:jarvis_app/Components/recent_list_chat.dart';
import 'package:jarvis_app/Components/screen_loader.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:sqflite/sqflite.dart';
import '../Components/Utilities/BackendUtilities/friends.dart';
import '../Components/Utilities/BackendUtilities/profile_user.dart';
import '../Components/Utilities/SqfliteHelperClasses/contact_list_database_helper.dart';
import '../Components/Utilities/extras.dart';
import '../Components/cache_image.dart';
import 'package:uuid/uuid.dart';


class AddNewUsersPage extends StatefulWidget {
  const AddNewUsersPage({super.key});

  @override
  State<AddNewUsersPage> createState() => _AddNewUsersPageState();
}

class _AddNewUsersPageState extends State<AddNewUsersPage> {
  late final Database db;

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
  int maxGroupSize = 10;
  bool progressVisible = false;

  final storage = const FlutterSecureStorage();

  int _currentPageIndex = 1;
  final _controller = PageController(
      initialPage: 1
  );

  List<Map<String, dynamic>> userContactList = [];
  List<Map<String, dynamic>> filteredUserRecentsList = [];
  List<Map<String, dynamic>> previousUserRecentsList = [];
  List<Map<String, dynamic>> newGroupUserList = [];

  // Map to track user add selection state of each user in a new group
  Map<int, bool> isUserSelectedMap = {};

  @override
  void initState() {
    super.initState();
    // _initializeDatabase();
    initNewGroupUserList();
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

  Future<void> _initializeDatabase() async {
    db = await ContactListDatabaseHelper().database;
  }

  Future<void> initNewGroupUserList() async {
    String userId = await Extras().retrieveUserID();
    Map<String, dynamic> profileDetails = await ProfileUser().retrieveProfileDetails(
      await Extras().retrieveJWT(),
      userId,
      false,
    );
    newGroupUserList = [{
      'name': '(You)',
      'profileImage': profileDetails['profile']['profilepicture'] ?? '',
      'userId': userId,
      'userIndex': 0
    }];
    // setState(() {
    //   newGroupUserList = [{
    //     'name': '(You)',
    //     'profileImage': profileDetails['profile']['profilepicture'] ?? '',
    //     'userId': userId,
    //     'userIndex': 0
    //   }];
    // });
  }

  Future<void> readContactListFromStorage() async {
    final contactList = await ContactListDatabaseHelper().getAllContacts();

    if (contactList.isEmpty) {
      await retrieveAndStoreContactListFromOnline();
      final updatedContactList = await ContactListDatabaseHelper().getAllContacts();
      setState(() {
        if(updatedContactList.isNotEmpty){
          userContactList = updatedContactList;
        } else {
          userContactList = [];
        }
      });
    } else {
      setState(() {
        userContactList = contactList;
      });
    }
  }

  Future<void> retrieveAndStoreContactListFromOnline() async {
    String userId = await Extras().retrieveUserID();
    Map<String, dynamic> friends = await Friends().retrieveFriendList(await Extras().retrieveJWT());
    List<dynamic> conversations = await SendReceiveMessages().retrieveConversations(await Extras().retrieveJWT(), userId);
    if(friends.isEmpty){
      return;
    }
    for (var friend in friends['friends']) {
    String friendId = friend['id'] ?? '';
    String username = friend['username'] ?? '';
    String conversationId = '';

    for (var conversation in conversations) {
      List<dynamic> participants = conversation['participants'];
      if (participants.contains(userId) && participants.contains(friendId) && participants.length == 2) {
        conversationId = conversation['_id'];
        break;
      }
    }

    await addingContactToLocalDatabase(friendId, username, conversationId);
    }
  }

  Future<void> saveContactToStorage(Map<String, dynamic> userContact) async {
    await ContactListDatabaseHelper().insertContact(userContact);
  }

  void _updateUserSelectionState() {
    int index = 1;
    setState(() {
      isUserSelectedMap = {};
    });
    for (var _ in userContactList) {
      isUserSelectedMap[index++] = false;
    }
  }

  void changeIsUserSelected(int index) {
    if (newGroupUserList.length >= maxGroupSize) {
      return;
    } else {
      setState(() {
        isUserSelectedMap[index] = !isUserSelectedMap[index]!;
      });
    }
  }

  void updateProgressVisible() {
    setState(() {
      progressVisible = !progressVisible;
    });
  }

  void addingUsersToNewGroup(String name, String profileImage, int userIndex, String userId) {
    if (newGroupUserList.length >= maxGroupSize){
      InAppNotifications.show(
        description: "Can't add more users to the group",
        onTap: (){}
      );
    } else {
      Map<String, dynamic> newUser = {
        'name': Extras().capitalize(name),
        'profileImage': profileImage,
        'userId': userId,
        'userIndex': userIndex
      };
      setState(() {
        newGroupUserList.add(newUser);
      });
    }
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

  Future<void> addingGroupContact() async {
    List<String> participantsID = [];
    String myId = await Extras().retrieveUserID();
    for (var newGroupUser in newGroupUserList) {
      if(newGroupUser['userId'] != myId){
        participantsID.add(newGroupUser['userId']);
      }
    }
    String conversationId = await SendReceiveMessages().createConversationBackend(participantsID, await Extras().retrieveJWT());
    addingGroupContactToLocalDatabase(participantsID, conversationId);
  }

  Future<void> addingGroupContactToLocalDatabase(
      List<String> participantsId,
      String conversationId
      ) async {
    List<String> images = ['', '', ''];
    List<String> participantNames = [];

    participantsId.insert(0, await Extras().retrieveUserID());

    for (int i = 0; i < participantsId.length; i++) {
      String friendID = participantsId[i];
      if (friendID.isNotEmpty) {
        await SendReceiveMessages()
            .retrieveFriendProfile(friendID, await Extras().retrieveJWT())
            .then((profile) {
          String profileImage = profile['profileImage'] ?? '';
          String fullName = profile['chatName'] ?? '';

          // Collect profile images for the first three participants
          if (i < 3) {
            images[i] = profileImage;
          }
          // Collect participant names
          participantNames.add(fullName.split(' ').first);
        });
      }
    }

    String displayedNames;
    if (participantNames.length > 3) {
      displayedNames = '${participantNames[0]}, ${participantNames[1]}, ${participantNames[2]}, and others';
    } else if (participantNames.length == 3) {
      displayedNames = '${participantNames[0]}, ${participantNames[1]}, and ${participantNames[2]}';
    } else if (participantNames.length == 2) {
      displayedNames = '${participantNames[0]} and ${participantNames[1]}';
    } else {
      displayedNames = participantNames.join(', ');
    }

    // Create the user contact entry
    Map<String, dynamic> userContact = {
      'userImage3': images[2],
      'numberOfUsers': participantsId.length.toString(),
      'isGroup': true,
      'userImage': images[0],
      'userImage2': images[1],
      'name': displayedNames.toLowerCase(),
      'userName': conversationId,
      'groupImage': '',
      'conversationId': conversationId,
      'userBio': 'A place for us to stay connected!',
      'participantsId': participantsId.join(',')
    };

    // Format for saving to database, setting `isGroup` as an integer
    Map<String, dynamic> userContactDatabase = {
      ...userContact,
      'isGroup': 1,  // 1 indicates true for `isGroup` in database
    };

    // Update user contact list and save to database
    setState(() {
      userContactList = [...userContactList, userContact];
    });
    saveContactToStorage(userContactDatabase);
    resetGroupSelection(false);
  }


  Future<void> addingNormalContact(String userName, String jwtToken) async {
    final bool userExists = userContactList.any((contact) => (contact['name'] as String).toLowerCase() == userName.toLowerCase());

    if (userExists) {
      InAppNotifications.show(
        description: "User already exists in your contact list",
        onTap: (){}
      );
      return;
    }
    String friendID = await Friends().addUserToFriendList(jwtToken, userName);
    String? conversationId = await ChatListDatabaseHelper().getConversationIdByUserName(userName);
    conversationId ??= await SendReceiveMessages().createConversationBackend([friendID], await Extras().retrieveJWT());
    addingContactToLocalDatabase(friendID, userName, conversationId);
  }

  Future<void> addingContactToLocalDatabase(
      String friendID, String userName, String conversationId
      ) async {
    if (friendID.isEmpty) return;
    final jwt = await Extras().retrieveJWT();
    final profile = await SendReceiveMessages().retrieveFriendProfile(friendID, jwt);
    final profileImage = profile['profileImage'] ?? '';
    final bio = profile['bio'] ?? '';
    final chatName = profile['chatName']?.toLowerCase() ?? '';
    final formattedUserName = userName.toLowerCase();
    final participantsId = [friendID];

    final userContact = {
      'userImage3': '',
      'numberOfUsers': (participantsId.length - 1).toString(),
      'isGroup': false,
      'userImage': profileImage,
      'userImage2': '',
      'name': chatName,
      'userName': formattedUserName,
      'groupImage': '',
      'conversationId': conversationId,
      'userBio': bio,
      'participantsId': participantsId.join(',')
    };
    setState(() {
      userContactList = [...userContactList, userContact];
    });
    saveContactToStorage({
      ...userContact,
      'isGroup': 0, // Ensuring 'isGroup' is stored as an integer
    });
    resetContactSelection();
  }


  _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

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

  void resetGroupSelection(bool resetContactList) {
    initNewGroupUserList();
    setState(() {
      isAddingGroup = !isAddingGroup;
      if(resetContactList){
        userContactList = previousUserRecentsList;
      }
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
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 50),
              child: Column(
                children: [
                  backHeader(),
                  const SizedBox(
                    height: 20,
                  ),
                  searchChatListBody(),
                  SizedBox(
                    height: (_currentPageIndex == 1) ? 120 : (_currentPageIndex == 2) ? 215 : 200,
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
            ),
            LoadingAnimation(progressVisible: progressVisible)
          ],
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
                enableSuggestions: true,
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
            child: Container(
              color: Colors.transparent,
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
            )
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
                  description: "Cannot create a group with an empty contact list. Add a few friends first.",
                  onTap: () {}
                );
              }
            },
            child: Container(
              color: Colors.transparent,
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
          )
        ],
      ),
    );
  }

  Widget contactList() {
    List<Widget> buildRecentListChatWidgets(List<Map<String, dynamic>> contactList) {
      return contactList.asMap().entries.map((entry) {
        final int userIndex = entry.key + 1;
        final entryValue = entry.value;
        final participantsId = entryValue['participantsId'];
        final participantsIdString = participantsId is String ? participantsId : participantsId.join(",");
        return RecentListChat(
          isGroup: entryValue['isGroup'],
          userImage: entryValue['userImage'],
          userImage2: entryValue['userImage2'],
          userImage3: entryValue['userImage3'],
          numberOfUsers: entryValue['numberOfUsers'],
          name: entryValue['name'],
          userName: entryValue['userName'],
          groupImage: entryValue['groupImage'],
          isAddingGroup: isAddingGroup,
          addingUsersToNewGroup: addingUsersToNewGroup,
          isUserSelected: isUserSelectedMap[userIndex] ?? false,
          changeIsUserSelected: () => changeIsUserSelected(userIndex),
          userIndex: userIndex,
          conversationId: entryValue['conversationId'],
          participantsId: participantsIdString,
          userBio: entryValue['userBio'],
          isPinned: entryValue['isPinned'] == 1,
          isArchived: entryValue['isArchived'] == 1
        );
      }).toList();
    }

    final userContactListWidgets = buildRecentListChatWidgets(userContactList);
    final filteredUserRecentsListWidgets = buildRecentListChatWidgets(filteredUserRecentsList);

    return Padding(
      padding: EdgeInsets.only(
        left: 5,
        top: (_currentPageIndex == 1) ? 20 : 0,
        bottom: 10,
      ),
      child: Column(
        children: [
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
                    (_searchFocusNode.hasFocus)
                        ? Lottie.asset(
                      'assets/lottie_animations/nothing_found_animation.json',
                      width: 80,
                    )
                        : Lottie.asset(
                      'assets/lottie_animations/no_contact_animation.json',
                      width: 80,
                    ),
                    Text(
                      (_searchFocusNode.hasFocus)
                          ? 'Search result not found'
                          : 'You have no saved friends or groups',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontFamily: 'Inter',
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SingleChildScrollView(
              child: Column(
                children: (_searchController.text.isEmpty)
                    ? userContactListWidgets
                    : filteredUserRecentsListWidgets,
              ),
            ),
          ),
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
                      fontWeight: (entry['userIndex'] == 0) ? FontWeight.w800 : FontWeight.w400,
                      color: Theme.of(context).colorScheme.scrim,
                      fontFamily: 'Inter',
                    ),),
                )
              ],
            ),
          ),
          Visibility(
            visible: (entry['userIndex'] == 0) ? false : true,
            child: Positioned(
              top: 25,
              right: 20,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          newGroupUserList.removeWhere((user) => user['name'] == entry['name']);
                          changeIsUserSelected(entry['userIndex']);
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        size: 8,
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                      padding: EdgeInsets.zero, // Remove default padding
                      constraints: const BoxConstraints(), // Remove constraints to allow precise positioning
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10), //top was 10 when editGroupName was active
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        resetGroupSelection(true);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Theme.of(context).colorScheme.scrim,
                      )),
                  Text(
                    'Create New Group',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: Theme.of(context).colorScheme.scrim,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${newGroupUserList.length} / $maxGroupSize',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    onPressed: () {
                      if (newGroupUserList.length > 1){
                        updateProgressVisible();
                        addingGroupContact();
                        updateProgressVisible();
                      } else {
                        InAppNotifications.show(
                            description: 'You cannot create a group with just you',
                            onTap: (){}
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
          )
        ],
      )
    );
  }

  Widget addingNewUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10),
      child: Stack(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    resetContactSelection();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Theme.of(context).colorScheme.scrim,
                  )),
              Text('Add New Contact', style:  TextStyle(
                  fontFamily: 'Inter',
                  color: Theme.of(context).colorScheme.scrim,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                newContactFields(),
                const SizedBox(height: 10,),
                Visibility(
                  visible: true,
                  child: TextButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      updateProgressVisible();
                      if(_usernameController.text.isNotEmpty){
                        String username = await Extras().retrieveUsername();
                        if((_usernameController.text).toLowerCase() == username.toLowerCase()){
                          InAppNotifications.show(
                              description: "Cannot add your username as a friend",
                              onTap: () {}
                          );
                          updateProgressVisible();
                          return;
                        }
                        String jwtToken = await Extras().retrieveJWT();
                        if(jwtToken != '') {
                          bool doesUserExist = await Friends().checkIfUserExists(jwtToken, _usernameController.text.toLowerCase());
                          if(doesUserExist){
                            await addingNormalContact(_usernameController.text.toLowerCase(), jwtToken);
                          }
                        }
                      } else{
                        InAppNotifications.show(
                            description: 'Username field is empty',
                            onTap: () {}
                        );
                      }
                      updateProgressVisible();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
