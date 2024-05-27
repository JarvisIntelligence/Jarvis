import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/AIChats/AI_chat_history.dart';
import 'package:jarvis_app/Components/cache_image.dart';
import 'package:jarvis_app/Components/chat_bubble.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.chatName, required this.isGroup, this.userImage, this.userImage2});

  final String chatName;
  final bool isGroup;
  final String? userImage;
  final String? userImage2;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF090A0A),
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width, // Set width to match screen width,
        child: const AiChatHistory(),
      ),
      body: Column(
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20,),
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
                            child: CacheImage(imageUrl: widget.userImage ?? '', isGroup: widget.isGroup,),
                          ),
                          Positioned(
                            right: -3,
                            bottom: -3,
                            child: CacheImage(imageUrl: widget.userImage2 ?? '', isGroup: widget.isGroup,),
                          ),
                        ],
                      ),
                    ) //One person
                        :
                    CacheImage(imageUrl: widget.userImage ?? '', isGroup: widget.isGroup,),
                    const SizedBox(height: 5,),//Two people/Group
                    Text(widget.chatName, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),)
                  ],
                ),
                Visibility(
                    visible: (widget.chatName == 'JARVIS AI') ? true : false,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        icon: SvgPicture.asset('assets/icons/hamburger_icon.svg', height: 20,),
                      ),
                    )
                ),
              ],
            ),
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text('Nov 20, 2023', style: TextStyle(color: Color(0xFF979C9E), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
                      ),
                      ChatBubble(message: "When I opted to leave McD’s - was a night manager - I sent in my customary 2-weeks notice. The day they got the letter I was asked to come in, return my shirts and keys, and depart. They didn’t want a short-timer having access to the safe, least of all in the wee hours when the store was closed (this was also just before they got a drive-in, and before 24-hour openings were common. Yeah, dinosaurs roamed the parking lots, too… Moses was in my high school yearbook, all that.).",
                        isSender: true,
                        chatName: widget.chatName,
                        isGroup: widget.isGroup,
                      ),
                      ChatBubble(message: "Hello...",
                        isSender: false,
                        chatName: widget.chatName,
                        isGroup: widget.isGroup,
                      )
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Adjusts padding based on keyboard
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                  onPressed: (){},
                  icon: const Icon(Icons.camera_alt, color: Color(0xFFCDCFD0),)
              ),
              IconButton(
                  onPressed: (){},
                  icon: SvgPicture.asset('assets/icons/attach_icon.svg', height: 20,)
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      width: 1, // Adjust width as needed
                      color: const Color(0x40ffffff), // Adjust color as needed
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                          cursorColor: const Color(0xFF979C9E),
                          decoration: const InputDecoration(hintText: 'Message',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xFF979C9E), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: (){},
                          icon: SvgPicture.asset('assets/icons/send_icon.svg', height: 30,)
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
