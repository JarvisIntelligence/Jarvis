import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PreviousAiChat extends StatelessWidget {
  const PreviousAiChat({super.key,
    required this.chatName, required this.isNewChat,
    required this.switchShowShareDeleteAiChat
  });

  final String chatName;
  final bool isNewChat;
  final Function switchShowShareDeleteAiChat;

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
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(Icons.messenger_outline, color: Theme.of(context).colorScheme.scrim, size: 20,),
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 150, // Set the desired width
                      child: Text(
                        chatName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.scrim,
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
                          onPressed: (){
                            switchShowShareDeleteAiChat();
                          },
                          icon: Icon(Icons.more_vert, size: 20, color: Theme.of(context).colorScheme.scrim,)
                      ),
                    ),
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.arrow_forward, size: 20, color: Theme.of(context).colorScheme.scrim,)
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
                color: (isNewChat) ? Theme.of(context).colorScheme.primaryFixed : Theme.of(context).colorScheme.tertiaryFixedDim,
              )
          )
        ],
      ),
    );
  }
}
