import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/AIChats/AI_chat_history.dart';
import 'package:jarvis_app/Components/cache_image.dart';
import 'package:jarvis_app/Components/chat_bubble.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';
import 'package:lottie/lottie.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;


class Chat extends StatefulWidget {
  const Chat({super.key, required this.chatName,
    required this.isGroup,  required this.userImage,
    this.userImage2, required this.id,
    this.userImage3, required this.numberOfUsers});

  final String chatName;
  final bool isGroup;
  final String userImage;
  final String? userImage2;
  final String id;
  final String numberOfUsers;
  final String? userImage3;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();
  final AutoScrollController scrollController = AutoScrollController();
  final FocusNode focusNode = FocusNode();
  bool showScrollBottomButton = false;
  bool emojiShowing = false;
  double keyboardHeight = 0.0;
  bool isCopyMessageVisible = false;
  bool isReply = false;
  String replyMessage = '';
  String replyName = '';
  String currentReplyMessage = '';
  bool isLongPressed = false;
  int numberOfSelectedBubbles = 0;
  // Map to track chat selection state of each chat bubble
  Map<int, bool> isChatSelectedMap = {};

  // List<Map<String, dynamic>> userChat = [];
  List<Map<String, dynamic>> userChat = [
    {
      'Jun 6, 2024': [
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-05T08:15:00'),
          'message': "Hey, are you coming to the gym later?",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-05T08:20:00'),
          'message': "Yes, I'll be there at 6 PM.",
          'senderName': "Mia",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-05T12:00:00'),
          'message': 'Can we reschedule our meeting?',
          'senderName': 'Sophia',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-05T12:05:00'),
          'message': 'Sure, how about tomorrow afternoon?',
          'senderName': 'Me',
          'isDelivered': true,
          'isSent': true
        },
      ],
      'Jun 7, 2024': [
        {
          'isSender': true,
          'isStarred': true,
          'time': DateTime.parse('2024-06-06T08:00:00'),
          'message': "Morning! Ready for the meeting today?",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-06T08:05:00'),
          'message': "Yes, all set. Let's do this!",
          'senderName': "Mason",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-06T11:30:00'),
          'message': 'Lunch break? Need a breather!',
          'senderName': 'Lucas',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-06T11:35:00'),
          'message': "Definitely. Let's go to that new place nearby.",
          'senderName': 'Me',
          'isDelivered': true,
          'isSent': true
        },
      ],
      'Jun 8, 2024': [
        {
          'isSender': true,
          'isStarred': true,
          'time': DateTime.parse('2024-06-07T14:15:00'),
          'message': "Just got back from my vacation. The beach was amazing!",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-07T14:17:00'),
          'message': "Wow, that sounds fantastic! Where did you go?",
          'senderName': "Oliver",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-07T15:00:00'),
          'message': "Went to Hawaii. The sunsets were incredible!",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-07T15:05:00'),
          'message': "I've always wanted to visit Hawaii. Lucky you!",
          'senderName': "Oliver",
          'isDelivered': true,
          'isSent': true
        },
      ],
      'Jun 9, 2024': [
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-08T09:00:00'),
          'message': "Good morning! Did you finish the project?",
          'senderName': "Sophia",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-08T09:05:00'),
          'message': "Good morning! Yes, I submitted it last night.",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-08T18:30:00'),
          'message': 'How about a movie tonight?',
          'senderName': 'Mia',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-08T18:35:00'),
          'message': 'Sounds great! Which movie?',
          'senderName': 'Me',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-08T19:00:00'),
          'message': 'How about the new superhero one?',
          'senderName': 'Mia',
          'isDelivered': true,
          'isSent': true
        },
      ],
      'Jun 10, 2024': [
        {
          'isSender': true,
          'isStarred': true,
          'time': DateTime.parse('2024-06-09T07:45:00'),
          'message': "Did you see the news this morning?",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-09T07:50:00'),
          'message': "Yes, it's unbelievable!",
          'senderName': "Ava",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-09T12:15:00'),
          'message': 'Are we still on for lunch?',
          'senderName': 'Ethan',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': false,
          'time': DateTime.parse('2024-06-09T12:20:00'),
          'message': 'Absolutely! See you at 1 PM?',
          'senderName': 'Me',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': false,
          'time': DateTime.parse('2024-06-09T12:25:00'),
          'message': "Perfect. I'll be there!",
          'senderName': 'Ethan',
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': true,
          'isStarred': true,
          'time': DateTime.parse('2024-06-09T18:45:00'),
          'message': "Did you get the email from the boss?",
          'senderName': "Me",
          'isDelivered': true,
          'isSent': true
        },
        {
          'isSender': false,
          'isStarred': true,
          'time': DateTime.parse('2024-06-09T18:50:00'),
          'message': "Yes, looks like we have a new project to work on.",
          'senderName': "James",
          'isDelivered': true,
          'isSent': true
        },
      ],
    }
  ];

  @override
  void initState() {
    super.initState();
    // automatically moves the screen to the bottom when a chat is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    scrollController.addListener(scrollListener);
    _initializeChatSelectionState();
    init();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> init() async {
    // retrieve user's chat list from secure storage
    List<Map<String, dynamic>>? test = await _secureStorageHelper.readListData(widget.id);
  }

  void scrollListener() {
    bool atBottom = scrollController.position.pixels == scrollController.position.maxScrollExtent;
    setState(() {
      showScrollBottomButton = !atBottom;
    });
  }

  // Scroll to the bottom of the chat
  void scrollToBottom() {
    scrollController.scrollToIndex(
      userChat.length - 1, // Scroll to the last index
      preferPosition: AutoScrollPosition.end,
    );
  }

  void scrollToReply(int index) {
    scrollController.scrollToIndex(
      5,
      preferPosition: AutoScrollPosition.middle,
    );
  }

  String formatDate(String dateString) {
    final inputFormat = DateFormat('MMM d, y');
    DateTime date = inputFormat.parse(dateString);
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (DateFormat.yMd().format(date) == DateFormat.yMd().format(now)) {
      return 'Today';
    } else if (DateFormat.yMd().format(date) == DateFormat.yMd().format(yesterday)) {
      return 'Yesterday';
    } else {
      return inputFormat.format(date); // Format as "Jun 5, 2024"
    }
  }

  void showCopyMessage () {
    setState(() {
      isCopyMessageVisible = !isCopyMessageVisible;
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isCopyMessageVisible = !isCopyMessageVisible;
      });
    });
  }

  void showReplyMessage (String replyMessage, String replyName) {
    if(!isReply){
      setState(() {
        isReply = !isReply;
      });
    }
    updateReplyMessage(replyMessage, replyName);
  }

  void updateReplyMessage(String message, String name) {
    setState(() {
      replyMessage = message;
      replyName = name;
    });
  }

  void changeIsLongPressed() {
    setState(() {
      isLongPressed = true;
    });
  }

  void increaseDecreaseNumberOfSelectedBubbles (String increaseOrDecrease) {
    setState(() {
      if (increaseOrDecrease == 'increase') {
        numberOfSelectedBubbles++;
      } else {
        numberOfSelectedBubbles--;
        if (numberOfSelectedBubbles == 0){
          isLongPressed = !isLongPressed;
        }
      }
    });
  }

  void _initializeChatSelectionState() {
    int index = 0;
    for (var chatDateMap in userChat) {
      chatDateMap.forEach((date, messages) {
        for (var message in messages) {
          isChatSelectedMap[index++] = false;
        }
      });
    }
  }

  void changeIsChatSelected(int index) {
    setState(() {
      isChatSelectedMap[index] = !isChatSelectedMap[index]!;
    });
  }

  void _deselectAllChats() {
    setState(() {
      isChatSelectedMap.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF090A0A),
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        width: MediaQuery
            .of(context)
            .size
            .width, // Set width to match screen width,
        child: const AiChatHistory(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              chatHeader(),
              chatMessagesScreen()
            ],
          ),
          scrollToBottomButton(),
          copyMessage(),
          messagesSelectedDisplay()
        ],
      ),
      bottomNavigationBar: chatInputBar(),
    );
  }

  Widget chatHeader(){
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 50),
      color: const Color(0xFF303437),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back, color: Colors.white, size: 20,),
            ),
          ),
          Column(
            children: [
              (widget.chatName == 'JARVIS AI') ?
              SvgPicture.asset(
                'assets/icons/ai_logo.svg',
                height: 40,
              ) //JARVIS AI Logo
                  :
              (widget.isGroup)
                  ? (int.parse(widget.numberOfUsers) > 2)
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 23, // Third image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage3 ?? '', // Change this to the third user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 13, // Second image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage2 ?? '', // Change this to the second user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 0, // First image position
                              child: CacheImage(
                                  imageUrl: widget.userImage, // Change this to the first user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -3,
                              top: -3,
                              child: CacheImage(
                                  imageUrl: widget.userImage,
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers),
                            ),
                            Positioned(
                              right: -3,
                              bottom: -3,
                              child: CacheImage(
                                imageUrl: widget.userImage2 ?? '',
                                isGroup: widget.isGroup,
                                numberOfUsers: widget.numberOfUsers,),
                            ),
                          ],
                        ),
                      )
                  : CacheImage(numberOfUsers: widget.numberOfUsers, imageUrl: widget.userImage, isGroup: widget.isGroup,),
              const SizedBox(height: 5,), //Two people/Group
              Text(widget.chatName, style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400),)
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: (widget.chatName == 'JARVIS AI')
                ? IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: SvgPicture.asset(
                'assets/icons/hamburger_icon.svg', height: 20,),
            )
                : IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, size: 20, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessagesScreen() {
    List<Widget> chatWidgets = [];
    bool isFirstDate = true;
    int index = 0;

    for (var chatDateMap in userChat) {
      chatDateMap.forEach((date, messages) {
        String formattedDate = formatDate(date);
        chatWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10, top: (isFirstDate) ? 0 : 20),
            child: Text(
              formattedDate,
              style: const TextStyle(
                color: Color(0xFF979C9E),
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
        isFirstDate = false;
        for (int i = 0; i < messages.length; i++) {
          var message = messages[i];
          bool hasDifferentSender = false;
          if (i < messages.length - 1) {
            hasDifferentSender = messages[i + 1]['isSender'] != message['isSender'];
          }

          // Capture the correct index for the closure
          final currentIndex = index;
          chatWidgets.add(
            ChatBubble(
                message: message['message'],
                isSender: message['isSender'],
                isStarred: message['isStarred'],
                showCopyMessage: showCopyMessage,
                chatName: 'Chat Name', // Replace with actual chatName
                isGroup: widget.isGroup, // Replace with actual isGroup value if needed
                chatTime: DateFormat('HH:mm').format(message['time']), // Replace with actual chatTime if needed
                senderName: message['senderName'],
                isDelivered: message['isDelivered'],
                isSent: message['isSent'],
                showReplyMessage: showReplyMessage,
                hasDifferentSender: hasDifferentSender,
                isLongPressed: isLongPressed,
                changeIsLongPressed: changeIsLongPressed,
                increaseDecreaseNumberOfSelectedBubbles: increaseDecreaseNumberOfSelectedBubbles,
                numberOfSelectedBubbles: numberOfSelectedBubbles,
                isChatSelected: isChatSelectedMap[currentIndex] ?? false,
                changeIsChatSelected: () => changeIsChatSelected(currentIndex)
            ),
          );
          index++;
        }
      });
    }

    if (chatWidgets.isNotEmpty) {
      chatWidgets.add(const SizedBox(height: 30));
    }

    return Expanded(
      child: (userChat.isEmpty)
          ? buildEmptyChat()
          : buildChat(chatWidgets),
    );
  }

  Widget buildEmptyChat() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          padding: EdgeInsets.zero,
          controller: scrollController,
          children: [
            Column(
              children: [
                Lottie.asset((widget.chatName == 'JARVIS AI')
                    ? 'assets/lottie_animations/new_ai_chat_animation.json'
                    : 'assets/lottie_animations/new_user_chat_animation.json', width: 80),
                SizedBox(height: (widget.chatName == 'JARVIS AI') ? 0 : 10,),
                const Text('Quiet around here..start a conversation', style: TextStyle(color: Color(0xFFCDCFD0), fontFamily: 'Inter', fontSize: 8),)
              ],
            ),
          ],
        )
    );
  }

  Widget buildChat(List<Widget> chatWidgets) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 20),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        controller: scrollController,
        itemCount: userChat.length,
        itemBuilder: (context, index) {
          return AutoScrollTag(
            index: index,
            controller: scrollController,
            key: ValueKey(index), // Unique key for ListView.builder
            child: Column(
                children: chatWidgets
            ),
          );
        },
      ),
    );
  }

  Widget scrollToBottomButton() {
    return Visibility(
      visible: (showScrollBottomButton) ? true : false,
      child: Positioned(
          bottom: 40,
          right: 10,
          child: ElevatedButton(
            onPressed: () {
              scrollToBottom();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF6B4EFF),
            ),
            child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20,),
          )
      ),
    );
  }

  Widget copyMessage() {
    return Visibility(
      visible: isCopyMessageVisible,
      child: Positioned(
        child:  Center(
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E5E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Message copied!',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontFamily: 'Inter'
                  ),),
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget chatInputBar() {
    // Listen to changes in viewInsets (keyboard height)
    final viewInsets = MediaQuery.of(context).viewInsets;
    if (viewInsets.bottom != 0.0) {
      setState(() {
        keyboardHeight = viewInsets.bottom;
      });
    }
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom), // Adjusts padding based on keyboard
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            replyContainer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 70,
              decoration: const BoxDecoration(
                  color: Color(0xFF090A0A),
                  border: Border(
                      top: BorderSide(color: Color(0xFF202325), width: 1)
                  )
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Color(0xFFCDCFD0),),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/attach_icon.svg', height: 20,)
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 1, // Adjust width as needed
                          color: const Color(
                              0x40ffffff), // Adjust color as needed
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  if (emojiShowing) {
                                    // Wait for a brief moment to ensure the emojiSelector is hidden
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      SystemChannels.textInput.invokeMethod('TextInput.show');
                                    });
                                    emojiShowing = !emojiShowing;
                                  } else {
                                    // Wait for a brief moment to ensure the keyboard is hidden
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      setState(() {
                                        emojiShowing = !emojiShowing; // Then, show the emoji selector
                                      });
                                    });
                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                  }
                                });
                              },
                              icon: SvgPicture.asset(
                                (emojiShowing) ? 'assets/icons/keyboard_icon.svg' : 'assets/icons/emoji_icon.svg', height: 30,)
                          ),
                          Expanded(
                            child: TextField(
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: messageController,
                              focusNode: focusNode,
                              style: const TextStyle(color: Color(0xFFE7E7FF),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400),
                              cursorColor: const Color(0xFF979C9E),
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFF979C9E),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset('assets/icons/send_icon.svg',
                                height: 30,)
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                      },
                      icon: const Icon(Icons.mic, color: Color(0xFFCDCFD0),)
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                height: keyboardHeight,
                child: EmojiPicker(
                  textEditingController: messageController,
                  config: Config(
                    height: 20,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 26 *
                            (foundation.defaultTargetPlatform == TargetPlatform.iOS
                                ?  1.20
                                :  1.0),
                        backgroundColor: Colors.white,
                        columns: 8,
                        noRecents: const Text('No Recents',
                            style: TextStyle(
                                fontSize: 10, fontFamily: 'Inter',
                                color: Color(0xFF090A0A)),
                            textAlign: TextAlign.center)
                    ),
                    swapCategoryAndBottomBar: true,
                    skinToneConfig: const SkinToneConfig(
                      enabled: true,
                      indicatorColor: Color(0xFF6B4EFF),
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                        indicatorColor: Color(0xFF6B4EFF),
                        iconColorSelected: Color(0xFF6B4EFF),
                        backgroundColor: Colors.white
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                        backgroundColor: Colors.white,
                        buttonIconColor: Color(0xFF6B4EFF),
                        buttonColor: Colors.transparent
                    ),
                    searchViewConfig: const SearchViewConfig(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget replyContainer() {
    return Visibility(
      visible: isReply,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        padding: const EdgeInsets.only(right: 15, left: 20, top: 15, bottom: 15),
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF9783FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Replying $replyName',
                      style: const TextStyle(
                          color: Color(0xFFABAFB1),
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),),
                    const SizedBox(width: 10,),
                    const Icon(Icons.reply, color: Color(0xFFABAFB1),)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    int replyIndex = 1; // Replace with the actual index
                    scrollToReply(replyIndex);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width - 130,
                        child: Text(replyMessage,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      Image.asset('assets/icons/linking_icon.png', width: 25,)
                    ],
                  ),
                )
              ],
            ),
            Positioned(
                top: -15,
                right: -10,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isReply = !isReply;
                    });
                  },
                  icon: const Icon(Icons.close, color: Color(0xFF303437), size: 14,),
                )
            )
          ],
        ),
      )
    );
  }

  Widget messagesSelectedDisplay() {
    return Visibility(
      visible: isLongPressed,
      child: Stack(
        children: [
          Positioned(
            top: 200,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFc0b5f9),
              ),
              child: Center(
                child: Text(
                  numberOfSelectedBubbles.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 195,
              right: 15,
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
                        isLongPressed = !isLongPressed;
                        numberOfSelectedBubbles = 0;
                        _deselectAllChats();
                      });
                    },
                    icon: const Icon(Icons.close, size: 5, color: Colors.white,),
                  ),
                ),
              )
          ),
        ],
      )
    );
  }
}
