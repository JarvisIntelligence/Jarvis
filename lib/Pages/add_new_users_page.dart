import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/recent_list_chat.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:sqflite/sqflite.dart';
import '../Components/Utilities/BackendUtilities/friends.dart';
import '../Components/Utilities/SqfliteHelperClasses/contact_list_database_helper.dart';
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

  // List<Map<String, dynamic>> userContactList = [
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
  //     'userImage2': '',
  //     'name': 'Stephen Reed',
  //     'groupImage': '',
  //     'id': '1',
  //     'userBio': 'Loves outdoor adventures and a good cup of coffee.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
  //     'userImage2': '',
  //     'name': 'Maria Garcia',
  //     'groupImage': '',
  //     'id': '2',
  //     'userBio': 'Avid reader and aspiring author.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/20.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/20.jpg',
  //     'name': 'James & Maria',
  //     'groupImage': '',
  //     'id': '3',
  //     'userBio': 'A small group of close friends who love to hang out and have fun.'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/men/16.jpg',
  //     'numberOfUsers': "3",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/36.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/27.jpg',
  //     'name': 'Project Team',
  //     'groupImage': '',
  //     'id': '4',
  //     'userBio': 'Dedicated team working on innovative projects together.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/12.jpg',
  //     'userImage2': '',
  //     'name': 'Robert Brown',
  //     'groupImage': '',
  //     'id': '5',
  //     'userBio': 'Tech enthusiast with a passion for coding.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/15.jpg',
  //     'userImage2': '',
  //     'name': 'Linda Davis',
  //     'groupImage': '',
  //     'id': '6',
  //     'userBio': 'Loves cooking and exploring new recipes.'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/women/22.jpg',
  //     'numberOfUsers': "3",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/18.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/19.jpg',
  //     'name': 'Marketing Team',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '7',
  //     'userBio': 'Creative and energetic team driving the company’s marketing efforts.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/23.jpg',
  //     'userImage2': '',
  //     'name': 'Barbara Martinez',
  //     'groupImage': '',
  //     'id': '8',
  //     'userBio': 'Fitness enthusiast who loves to stay active.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/24.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/women/22.jpg',
  //     'name': 'Paul & Susan',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '9',
  //     'userBio': 'Dynamic couple who enjoy exploring new cultures and cuisines.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/42.jpg',
  //     'userImage2': '',
  //     'name': 'Susan Taylor',
  //     'groupImage': '',
  //     'id': '10',
  //     'userBio': 'Artist with a passion for painting and design.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/35.jpg',
  //     'userImage2': '',
  //     'name': 'Kevin Wilson',
  //     'groupImage': '',
  //     'id': '11',
  //     'userBio': 'Music lover and guitar player.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/30.jpg',
  //     'userImage2': '',
  //     'name': 'Sophia Moore',
  //     'groupImage': '',
  //     'id': '12',
  //     'userBio': 'Graphic designer with a creative flair.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/22.jpg',
  //     'userImage2': '',
  //     'name': 'Michael Johnson',
  //     'groupImage': '',
  //     'id': '13',
  //     'userBio': 'Entrepreneur and startup founder.'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/women/30.jpg',
  //     'numberOfUsers': "4",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/men/22.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/23.jpg',
  //     'name': 'Design Team',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '14',
  //     'userBio': 'Innovative team creating stunning visual designs.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/32.jpg',
  //     'userImage2': '',
  //     'name': 'Olivia Taylor',
  //     'groupImage': '',
  //     'id': '15',
  //     'userBio': 'Fashionista with a passion for trends.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/44.jpg',
  //     'userImage2': '',
  //     'name': 'William Miller',
  //     'groupImage': '',
  //     'id': '16',
  //     'userBio': 'Sports fan and amateur athlete.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/40.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/36.jpg',
  //     'name': 'Friends Forever',
  //     'groupImage': '',
  //     'id': '17',
  //     'userBio': 'Best friends since childhood, inseparable and adventurous.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/28.jpg',
  //     'userImage2': '',
  //     'name': 'Emily Harris',
  //     'groupImage': '',
  //     'id': '18',
  //     'userBio': 'Loves hiking and being in nature.'
  //   },
  //   {
  //     'userImage3': 'https://randomuser.me/api/portraits/men/33.jpg',
  //     'numberOfUsers': "4",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/35.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/26.jpg',
  //     'name': 'Tech Innovators',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '19',
  //     'userBio': 'Forward-thinking group focused on tech advancements.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/19.jpg',
  //     'userImage2': '',
  //     'name': 'James Anderson',
  //     'groupImage': '',
  //     'id': '20',
  //     'userBio': 'Travel enthusiast with a love for photography.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/29.jpg',
  //     'userImage2': '',
  //     'name': 'Alice Campbell',
  //     'groupImage': '',
  //     'id': '21',
  //     'userBio': 'Avid gamer and technology geek.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/30.jpg',
  //     'userImage2': '',
  //     'name': 'Nathan Green',
  //     'groupImage': '',
  //     'id': '22',
  //     'userBio': 'Fitness trainer and health advocate.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/26.jpg',
  //     'userImage2': '',
  //     'name': 'Rebecca Martinez',
  //     'groupImage': '',
  //     'id': '23',
  //     'userBio': 'Creative writer with a passion for storytelling.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/34.jpg',
  //     'userImage2': '',
  //     'name': 'Daniel Wilson',
  //     'groupImage': '',
  //     'id': '24',
  //     'userBio': 'Entrepreneur with a focus on startups.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/32.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/31.jpg',
  //     'name': 'Book Club',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '25',
  //     'userBio': 'Book lovers who meet regularly to discuss their reads.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/40.jpg',
  //     'userImage2': '',
  //     'name': 'Sophia Adams',
  //     'groupImage': '',
  //     'id': '26',
  //     'userBio': 'Foodie with a passion for baking.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/40.jpg',
  //     'userImage2': '',
  //     'name': 'Jack Thompson',
  //     'groupImage': '',
  //     'id': '27',
  //     'userBio': 'Outdoor sports enthusiast and photographer.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/35.jpg',
  //     'userImage2': '',
  //     'name': 'Ella Johnson',
  //     'groupImage': '',
  //     'id': '28',
  //     'userBio': 'Fashion designer with a flair for elegance.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/38.jpg',
  //     'userImage2': '',
  //     'name': 'Alexander Martinez',
  //     'groupImage': '',
  //     'id': '29',
  //     'userBio': 'Music producer with a love for jazz.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/21.jpg',
  //     'userImage2': '',
  //     'name': 'Natalie Green',
  //     'groupImage': '',
  //     'id': '30',
  //     'userBio': 'Art curator and gallery manager.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/28.jpg',
  //     'userImage2': '',
  //     'name': 'Lucas Harris',
  //     'groupImage': '',
  //     'id': '31',
  //     'userBio': 'Game developer with a passion for VR technology.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/25.jpg',
  //     'userImage2': '',
  //     'name': 'Charlotte Wilson',
  //     'groupImage': '',
  //     'id': '32',
  //     'userBio': 'Dance instructor and choreographer.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/25.jpg',
  //     'userImage2': '',
  //     'name': 'Matthew Lewis',
  //     'groupImage': '',
  //     'id': '33',
  //     'userBio': 'Automotive engineer with a love for classic cars.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "2",
  //     'isGroup': true,
  //     'userImage': 'https://randomuser.me/api/portraits/women/20.jpg',
  //     'userImage2': 'https://randomuser.me/api/portraits/men/33.jpg',
  //     'name': 'Adventure Seekers',
  //     'groupImage': 'https://picsum.photos/150',
  //     'id': '34',
  //     'userBio': 'Group of friends who love exploring new places.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/22.jpg',
  //     'userImage2': '',
  //     'name': 'Zoe Davis',
  //     'groupImage': '',
  //     'id': '35',
  //     'userBio': 'Wellness coach and motivational speaker.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/26.jpg',
  //     'userImage2': '',
  //     'name': 'Ryan Johnson',
  //     'groupImage': '',
  //     'id': '36',
  //     'userBio': 'Travel photographer with a love for landscapes.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/34.jpg',
  //     'userImage2': '',
  //     'name': 'Ava Scott',
  //     'groupImage': '',
  //     'id': '37',
  //     'userBio': 'Literary critic with a passion for poetry.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/31.jpg',
  //     'userImage2': '',
  //     'name': 'David Clark',
  //     'groupImage': '',
  //     'id': '38',
  //     'userBio': 'Software developer with an interest in AI.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/women/24.jpg',
  //     'userImage2': '',
  //     'name': 'Hannah Lewis',
  //     'groupImage': '',
  //     'id': '39',
  //     'userBio': 'Passionate about sustainable living and environmentalism.'
  //   },
  //   {
  //     'userImage3': '',
  //     'numberOfUsers': "1",
  //     'isGroup': false,
  //     'userImage': 'https://randomuser.me/api/portraits/men/29.jpg',
  //     'userImage2': '',
  //     'name': 'Lucas Martin',
  //     'groupImage': '',
  //     'id': '40',
  //     'userBio': 'Startup founder and tech innovator.'
  //   }
  // ];

  List<Map<String, dynamic>> userContactList = [];
  List<Map<String, dynamic>> filteredUserRecentsList = [];
  List<Map<String, dynamic>> previousUserRecentsList = [];
  List<Map<String, dynamic>> newGroupUserList = [{
    'name': '(You)',
    'profileImage': 'https://randomuser.me/api/portraits/lego/6.jpg',
    'userIndex': 0
  }];

  // Map to track user add selection state of each user in a new group
  Map<int, bool> isUserSelectedMap = {};

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
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


  Future<void> readContactListFromStorage() async {
    final List<Map<String, dynamic>> contactList = await ContactListDatabaseHelper().getAllContacts();
    if (contactList.isNotEmpty){
      setState(() {
        userContactList = contactList;
      });
    } else {
      setState(() {
        userContactList = [];
      });
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

  void addingUsersToNewGroup(String name, String profileImage, int userIndex) {
    if (newGroupUserList.length >= maxGroupSize){
      InAppNotifications.show(
        description: "Can't add more users to the group",
        onTap: (){}
      );
    } else {
      Map<String, dynamic> newUser = {
        'name': name,
        'profileImage': profileImage,
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

  Future<void> addToContactList(String userName, String jwtToken) async {

    final bool userExists = userContactList.any((contact) => (contact['name'] as String).toLowerCase() == userName.toLowerCase());

    const uuid = Uuid();
    String uniqueId = uuid.v4();

    if (userExists) {
      InAppNotifications.show(
        description: "User already exists in your contact list",
        onTap: (){}
      );
      return;
    }
    bool isSavedOnline = await Friends().addUserToFriendList(jwtToken, userName);
    if (isSavedOnline) {
      final List<Map<String, dynamic>> copyUserContactList = [...userContactList];
      Map<String, dynamic> userContact = {
        'userImage3': '',
        'numberOfUsers': "1",
        'isGroup': false,
        'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
        'userImage2': '',
        'name': userName.toLowerCase(),
        'groupImage': '',
        'id': uniqueId.toString(),
        'userBio': 'I love Jollof rice and chicken so much that it can kill me'
      };
      Map<String, dynamic> userContactDatabase = {
        'userImage3': '',
        'numberOfUsers': "1",
        'isGroup': 0,
        'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
        'userImage2': '',
        'name': userName,
        'groupImage': '',
        'id': uniqueId.toString(),
        'userBio': 'I love Jollof rice and chicken so much that it can kill me'
      };
      copyUserContactList.add(userContact);
      setState(() {
        userContactList = copyUserContactList;
      });
      saveContactToStorage(userContactDatabase);
      resetContactSelection();
    }
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
      newGroupUserList = [{
        'name': '(You)',
        'profileImage': 'https://randomuser.me/api/portraits/lego/6.jpg',
        'userIndex': 0
      }];
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

  Future<String> retrieveJWT() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['jwt_token'];
    }
    return '';
  }

  Future<String> retrieveUsername() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['userName'];
    }
    return '';
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
            loadingAnimation()
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
                  description: "Cannot create a group with an empty contact list. Add a few friend first",
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
                        resetGroupSelection();
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
                  onPressed: () {
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
                        String username = await retrieveUsername();
                        if(_usernameController.text == username){
                          InAppNotifications.show(
                              description: "Cannot add your username as a friend",
                              onTap: () {}
                          );                          return;
                        }
                        String jwtToken = await retrieveJWT();
                        if(jwtToken != '') {
                          bool doesUserExist = await Friends().checkIfUserExists(jwtToken, _usernameController.text);
                          if(doesUserExist){
                            await addToContactList(_usernameController.text, jwtToken);
                          } else {
                            InAppNotifications.show(
                                description: 'User does not exist',
                                onTap: () {}
                            );
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

  Widget loadingAnimation() {
    return Visibility(
        visible: progressVisible,
        child: Container(
          color: Colors.black87,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Lottie.asset('assets/lottie_animations/loading_animation.json', width: 80),
          ),
        )
    );
  }
}
