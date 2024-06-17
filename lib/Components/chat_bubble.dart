import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message,
    required this.isSender,
    required this.isGroup, required this.chatTime,
    required this.senderName, required this.isDelivered,
    required this.isSent, required this.hasDifferentSender,
    required this.isStarred, required this.showCopyMessage,
    required this.showReplyMessage, required this.isLongPressed,
    required this.changeIsLongPressed, required this.increaseDecreaseNumberOfSelectedBubbles,
    required this.numberOfSelectedBubbles, required this.isChatSelected,
    required this.changeIsChatSelected, required this.storeCopyDetailsSecureStorage,
    required this.chatDate, required this.removeCopyDetailSecureStorage
  });

  final bool isSender;
  final String senderName;
  final String message;
  final bool isGroup;
  final bool isDelivered;
  final bool isSent;
  final String chatTime;
  final String chatDate;
  final bool hasDifferentSender;
  final bool isStarred;
  final Function() showCopyMessage;
  final Function() changeIsLongPressed;
  final Function(String increaseOrDecrease) increaseDecreaseNumberOfSelectedBubbles;
  final bool isLongPressed;
  final int numberOfSelectedBubbles;
  final Function(String replyMessage, String replyName) showReplyMessage;
  final bool isChatSelected;
  final Function() changeIsChatSelected;
  final Function(String entry) storeCopyDetailsSecureStorage;
  final Function(String entry) removeCopyDetailSecureStorage;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late bool isStarred;

  void handleReplyButtonPressed() {
    widget.showReplyMessage(widget.message, widget.senderName);
  }

  @override
  void initState() {
    super.initState();
    isStarred = widget.isStarred; // Initialize isStarred with widget.isStarred
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>chatOrder = [
      Stack(
        children: [
          BubbleSpecialThree(
            constraints: const BoxConstraints(
                maxWidth: 200,
                minHeight: 20
            ),
            text: widget.message,
            tail: true,
            isSender: widget.isSender,
            color: (widget.isSender)
                ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
                  ? const Color(0xFFc0b5f9)
                  : const Color(0xFF5538EE)
                : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
                  ? const Color(0xFFafb4b9)
                  : const Color(0xFF303437),
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400
            ),
            userName: (widget.isGroup && !widget.isSender) ? widget.senderName : null,
            userNameTextStyle: const TextStyle(
                color: Color(0xFF979C9E),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400
            ),
          ),
          Visibility(
            visible: isStarred,
            child: Positioned(
                left: (widget.isSender) ? 6 : null,
                right: (widget.isSender) ? null : 6,
                child: const Icon(Icons.star, size: 10, color: Colors.grey,)
            ),
          ),
        ],
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
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                  widget.removeCopyDetailSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${widget.message}');
                } else {
                  widget.increaseDecreaseNumberOfSelectedBubbles('increase');
                  widget.storeCopyDetailsSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${widget.message}');
                }
                widget.changeIsChatSelected();
                widget.changeIsLongPressed();
              },
              onTap: (){
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                  widget.removeCopyDetailSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${widget.message}');
                }
                if (widget.isLongPressed && !widget.isChatSelected){
                  widget.increaseDecreaseNumberOfSelectedBubbles('increase');
                  widget.storeCopyDetailsSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${widget.message}');
                }
                if (widget.isChatSelected || widget.isLongPressed) {
                  widget.changeIsChatSelected();
                }
              },
              child: Row(
                mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: (widget.isSender) ? reversedChatOrder : chatOrder
              ),
            ),
            chatBubbleOptions(),
          ],
        )
    );
  }

  Widget chatBubbleOptions () {
    return Visibility(
      visible: (widget.isChatSelected && widget.numberOfSelectedBubbles < 2),
      child: Padding(
        padding: EdgeInsets.only(bottom: (widget.hasDifferentSender) ? 0: 10, left: 20, top: 5, right: (widget.isSender) ? 20: 0),
        child: Row(
          mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){},
              child: SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 14,),
            ), // forward
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: () {
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                }
                FlutterClipboard.copy(widget.message);
                widget.changeIsChatSelected();
                widget.showCopyMessage();
              },
              child: const Icon(Icons.copy, size: 12, color: Color(0xFF979C9E),),
            ), // copy
            const SizedBox(width: 10,),
            GestureDetector(
                onTap: (){},
                child: Image.asset('assets/icons/push_pin_icon.png', width: 14, color: const Color(0xFF979C9E),)
            ), // pin
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                }
                setState(() {
                  isStarred = !isStarred;
                });
                widget.changeIsChatSelected();
              },
              child: Icon((isStarred)
                  ? Icons.star
                  : Icons.star_border_outlined,
                size: 14,
                color: (isStarred)
                    ? const Color(0xFF6B4EFF)
                    : const Color(0xFF979C9E),),
            ), // star
            const SizedBox(width: 10,),
            GestureDetector(
                onTap: handleReplyButtonPressed,
                child: Image.asset('assets/icons/reply_icon.png', width: 14, color: const Color(0xFF979C9E),)
            ), // reply
          ],
        ),
      ),
    );
  }
}
