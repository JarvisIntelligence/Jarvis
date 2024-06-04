import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message,
    required this.isSender, required this.chatName,
    required this.isGroup, required this.chatTime,
    required this.senderName, required this.isDelivered,
    required this.isSent, required this.hasDifferentSender
  });

  final bool isSender;
  final String senderName;
  final String message;
  final String chatName;
  final bool isGroup;
  final bool isDelivered;
  final bool isSent;
  final String chatTime;
  final bool hasDifferentSender;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool isChatSelected = false;

  @override
  Widget build(BuildContext context) {
    List<Widget>chatOrder = [
      BubbleSpecialThree(
        constraints: const BoxConstraints(
            maxWidth: 200,
            minHeight: 20
        ),
        text: widget.message,
        tail: true,
        isSender: widget.isSender,
        color: (widget.isSender)
            ? (isChatSelected) ? const Color(0xFFc0b5f9) : const Color(0xFF5538EE)
            : (isChatSelected) ? const Color(0xFFafb4b9) : const Color(0xFF303437),
        textStyle: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400
        ),
        userName: (widget.isGroup) ? widget.senderName : null,
        userNameTextStyle: const TextStyle(
            color: Color(0xFF979C9E),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400
        ),
      ),
      Text(widget.chatTime, style: const TextStyle(color: Color(0xFF979C9E), fontSize: 10),),
    ];
    List<Widget> reversedChatOrder = chatOrder.reversed.toList();

    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: (widget.hasDifferentSender) ? 20 : 0),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: (){
                setState(() {
                  isChatSelected = !isChatSelected;
                });
              },
              onTap: (){
                if(isChatSelected) {
                  setState(() {
                    isChatSelected = !isChatSelected;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: (widget.isSender) ? reversedChatOrder : chatOrder
              ),
            ),
            Visibility(
              visible: isChatSelected,
              child: Padding(
                padding: EdgeInsets.only(bottom: (widget.hasDifferentSender) ? 0: 10, left: 20, top: 5, right: (widget.isSender) ? 20: 0),
                child: Row(
                  mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){},
                      child: SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 10,),
                    ), // forward
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        FlutterClipboard.copy(widget.message);
                      },
                      child: const Icon(Icons.copy, size: 12, color: Color(0xFF979C9E),),
                    ), // copy
                    const SizedBox(width: 10,),
                    GestureDetector(
                        onTap: (){},
                        child: Image.asset('assets/icons/push_pin_icon.png', width: 13, color: const Color(0xFF979C9E),)
                    ), // pin
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        FlutterClipboard.copy(widget.message);
                      },
                      child: const Icon(Icons.star_border_outlined, size: 12, color: Color(0xFF979C9E),),
                    ), // star
                    const SizedBox(width: 10,),
                    GestureDetector(
                        onTap: (){},
                        child: Image.asset('assets/icons/reply_icon.png', width: 12, color: const Color(0xFF979C9E),)
                    ), // reply
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}
