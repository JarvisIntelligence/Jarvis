import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/AIChats/AI_chat_history.dart';
import 'package:jarvis_app/Components/cache_image.dart';
import 'package:jarvis_app/Components/chat_bubble.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.chatName, required this.isGroup, this.userImage, this.userImage2, required this.id});

  final String chatName;
  final bool isGroup;
  final String? userImage;
  final String? userImage2;
  final String id;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();
  final AutoScrollController scrollController = AutoScrollController();
  bool showScrollBottomButton = false;

  List<Map<String, dynamic>> userChat = [
    {
      'Nov 20, 2023': [
        {
          'isSender': true,
          'time': DateTime.parse('2023-05-24T09:24:00'),
          'message':
          "When I opted to leave McD’s - was a night manager - I sent in my customary 2-weeks notice. The day they got the letter I was asked to come in, return my shirts and keys, and depart. They didn't want a short-timer having access to the safe, least of all in the wee hours when the store was closed (this was also just before they got a drive-in, and before 24-hour openings were common. Yeah, dinosaurs roamed the parking lots, too… Moses was in my high school yearbook, all that.).",
          'senderName': "User",
          'isDelivered': true,
          'isSent': false
        },
        {
          'isSender': false,
          'time': DateTime.parse('2023-05-24T09:25:00'),
          'message': "Hello...",
          'senderName': "Stephen",
          'isDelivered': true,
          'isSent': false
        },
      ],
      'Nov 21, 2023': [
        {
          'isSender': true,
          'time': DateTime.parse('2023-05-24T10:00:00'),
          'message': "Hey there!",
          'senderName': "John",
          'isDelivered': true,
          'isSent': false
        },
        {
          'isSender': false,
          'time': DateTime.parse('2023-05-24T10:05:00'),
          'message': "Hi John!",
          'senderName': "Alice",
          'isDelivered': true,
          'isSent': false
        },
        {
          'isSender': false,
          'time': DateTime.parse('2023-05-24T20:20:00'),
          'message': 'You guys are boring 🙄',
          'senderName': 'Fisher',
          'isDelivered': true,
          'isSent': false
        },
      ],
      'Nov 22, 2023': [
        {
          'isSender': true,
          'time': DateTime.parse('2023-05-25T08:30:00'),
          'message': "Did you watch the game yesterday?",
          'senderName': "David",
          'isDelivered': true,
          'isSent': false
        },
        {
          'isSender': false,
          'time': DateTime.parse('2023-05-25T08:35:00'),
          'message': "Yes, it was amazing!",
          'senderName': "John",
          'isDelivered': true,
          'isSent': false
        },
        {
          'isSender': false,
          'time': DateTime.parse('2023-05-25T08:40:00'),
          'message': 'What are you up to?',
          'senderName': 'Sarah',
          'isDelivered': true,
          'isSent': false
        },
      ],
    }
  ];

  @override
  void initState() {
    super.initState();
    // automatically moves the screen to the bottom when a chat is opened
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    scrollController.addListener(scrollListener);
    init();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    // retrieve user's chat list from secure storage
    List<Map<String, dynamic>>? test = await _secureStorageHelper.readListData(widget.id);
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      setState(() {
        showScrollBottomButton = false;
      });
    } else {
      setState(() {
        showScrollBottomButton = true;
      });
    }
  }

  // Scroll to the bottom of the chat
  void scrollToBottom() {
    scrollController.scrollToIndex(
      userChat.length - 1, // Scroll to the last index
      preferPosition: AutoScrollPosition.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatWidgets = [];
    bool isFirstDate = true; // Flag to track if it's the first occurrence of a date

    for (var chatDateMap in userChat) {
      chatDateMap.forEach((date, messages) {
        // Add date header with padding conditionally based on isFirstDate flag
        chatWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10, top: (isFirstDate) ? 0 : 20),
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF979C9E),
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
        // Reset isFirstDate after the first occurrence
        isFirstDate = false;
        // Add chat bubbles for each message
        for (int i = 0; i < messages.length; i++) {
          var message = messages[i];
          // Check if the next chat bubble has a different isSender value
          bool hasDifferentSender = false;
          if (i < messages.length - 1) {
            hasDifferentSender = messages[i + 1]['isSender'] != message['isSender'];
          }
          chatWidgets.add(
            ChatBubble(
              message: message['message'],
              isSender: message['isSender'],
              chatName: 'Chat Name', // Replace with actual chatName
              isGroup: widget.isGroup, // Replace with actual isGroup value if needed
              chatTime: DateFormat('HH:mm').format(message['time']), // Replace with actual chatTime if needed
              senderName: message['senderName'],
              isDelivered: message['isDelivered'],
              isSent: message['isSent'],
              hasDifferentSender: hasDifferentSender, // Add this if you need to pass this information to the ChatBubble
            ),
          );
        }
      });
    }

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
              Container(
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
                        (widget.isGroup) // Chat name profile picture
                            ?
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: -3,
                                top: -3,
                                child: CacheImage(
                                  imageUrl: widget.userImage ?? '',
                                  isGroup: widget.isGroup,),
                              ),
                              Positioned(
                                right: -3,
                                bottom: -3,
                                child: CacheImage(
                                  imageUrl: widget.userImage2 ?? '',
                                  isGroup: widget.isGroup,),
                              ),
                            ],
                          ),
                        ) //One person
                            :
                        CacheImage(imageUrl: widget.userImage ?? '',
                          isGroup: widget.isGroup,),
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
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: scrollController,
                      itemCount: userChat.length,
                      itemBuilder: (context, index) {
                        return AutoScrollTag(
                          index: index,
                          controller: scrollController,
                          key: const ValueKey('ChatList'), // Unique key for ListView.builder
                          child: Column(
                            children: chatWidgets
                          ),
                        );
                      },
                    ),
                  ),
              ),
            ],
          ),
          Visibility(
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
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom), // Adjusts padding based on keyboard
        child: Container(
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
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            'assets/icons/emoji_icon.svg', height: 30,)
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
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
      ),
    );
  }
}
