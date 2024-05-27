import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isSender, required this.chatName, required this.isGroup});

  final bool isSender;
  final String message;
  final String chatName;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: (isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: (isSender)
                ?
            [
              const Text('9:05 AM', style: TextStyle(color: Color(0xFF979C9E), fontSize: 10),),
              Column(
                children: [
                  BubbleSpecialThree(
                    constraints: const BoxConstraints(
                        maxWidth: 200,
                        minHeight: 20
                    ),
                    text: message,
                    tail: true,
                    isSender: isSender,
                    delivered: true,
                    sent: false,
                    color: (isSender) ? const Color(0xFF5538EE) : const Color(0xFF303437),
                    textStyle: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  (isSender) ? const SizedBox() : Padding(
                    padding: const EdgeInsets.only(left: 20, top: 3),
                    child: (chatName == 'JARVIS AI') ?
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){},
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 10,),
                              const SizedBox(width: 3,),
                              const Text('Forward', style: TextStyle(fontSize: 8, fontFamily: 'Inter', fontWeight: FontWeight.w400, color: Color(0xFF979C9E)),)
                            ],
                          ),
                        ),
                        const SizedBox(width: 10,),
                        GestureDetector(
                          onTap: (){},
                          child: const Row(
                            children: [
                              Icon(Icons.copy, size: 12, color: Color(0xFF979C9E),),
                              SizedBox(width: 3,),
                              Text('Copy', style: TextStyle(fontSize: 8, fontFamily: 'Inter', fontWeight: FontWeight.w400, color: Color(0xFF979C9E)),)
                            ],
                          ),
                        )
                      ],
                    )
                        :
                    const SizedBox()
                    ,
                  ),
                ],
              ),
            ]
                :
            [
              BubbleSpecialThree(
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  minHeight: 20
                ),
                text: message,
                tail: true,
                isSender: isSender,
                color: (isSender) ? const Color(0xFF5538EE) : const Color(0xFF303437),
                textStyle: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400
                ),
                userName: (isGroup) ? chatName : null,
                userNameTextStyle: const TextStyle(
                    color: Color(0xFF979C9E),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400
                ),
              ),
              const Text('9:05 AM', style: TextStyle(color: Color(0xFF979C9E), fontSize: 10),),
            ],
          ),
          (isSender) ? const SizedBox() : Padding(
            padding: const EdgeInsets.only(left: 20, top: 3),
            child: (chatName == 'JARVIS AI') ?
            Row(
              children: [
                GestureDetector(
                  onTap: (){},
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 10,),
                      const SizedBox(width: 3,),
                      const Text('Forward', style: TextStyle(fontSize: 8, fontFamily: 'Inter', fontWeight: FontWeight.w400, color: Color(0xFF979C9E)),)
                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                GestureDetector(
                  onTap: (){
                    FlutterClipboard.copy(message);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 12, color: Color(0xFF979C9E),),
                      SizedBox(width: 3,),
                      Text('Copy', style: TextStyle(fontSize: 8, fontFamily: 'Inter', fontWeight: FontWeight.w400, color: Color(0xFF979C9E)),)
                    ],
                  ),
                )
              ],
            )
                :
            const SizedBox()
            ,
          ),
        ],
      )
    );
  }
}
