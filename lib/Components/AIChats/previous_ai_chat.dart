import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PreviousAiChat extends StatelessWidget {
  const PreviousAiChat({super.key, required this.chatName, required this.isNewChat});

  final String chatName;
  final bool isNewChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    (isNewChat)
                        ?
                    SvgPicture.asset('assets/icons/ai_icon.svg', height: 30,)
                        :
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.messenger_outline, color: Colors.white, size: 20,),
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 200, // Set the desired width
                      child: Text(
                        chatName,
                        style: TextStyle(
                          color: const Color(0xFFE7E7FF),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: isNewChat ? FontWeight.bold : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )

                  ],
                ),
                Row(
                  children: [
                    Visibility(
                      visible: (isNewChat) ? false : true,
                      child: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFFFFFFFF),)
                      ),
                    ),
                    IconButton(
                        onPressed: (){},
                        icon: const Icon(Icons.arrow_forward, size: 20, color: Color(0xFFFFFFFF),)
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(right: 10, left: 5),
              child: Container(
                height: 2,
                color: (isNewChat) ? const Color(0xFF5538EE) : const Color(0x66FFFFFF),
              )
          )
        ],
      ),
    );
  }
}
