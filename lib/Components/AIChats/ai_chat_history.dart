import 'package:flutter/material.dart';
import 'package:jarvis_app/Components/AIChats/previous_ai_chat.dart';

class AiChatHistory extends StatefulWidget {
  const AiChatHistory({super.key});

  @override
  State<AiChatHistory> createState() => _AiChatHistoryState();
}

class _AiChatHistoryState extends State<AiChatHistory> {
  final TextEditingController searchController = TextEditingController();
  bool showShareDeleteAiChat = false;

  void switchShowDeleteAiChat () {
    setState(() {
      showShareDeleteAiChat = !showShareDeleteAiChat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(top: 70, right: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 5),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary,),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondaryFixed, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                          cursorColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          decoration: InputDecoration(hintText: 'Search...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PreviousAiChat(chatName: 'New Chat', isNewChat: true, switchShowShareDeleteAiChat: switchShowDeleteAiChat), //Should be permanently fixed,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PreviousAiChat(chatName: 'Why is the sky blue?', isNewChat: false, switchShowShareDeleteAiChat: switchShowDeleteAiChat,),
                      PreviousAiChat(chatName: 'Why am I broke ?', isNewChat: false, switchShowShareDeleteAiChat: switchShowDeleteAiChat),
                      PreviousAiChat(chatName: 'Will Jarvis make money?', isNewChat: false, switchShowShareDeleteAiChat: switchShowDeleteAiChat),
                      PreviousAiChat(chatName: 'Crazy right ?', isNewChat: false, switchShowShareDeleteAiChat: switchShowDeleteAiChat)
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.tertiaryFixedDim,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 60, top: 30),
                    child: GestureDetector(
                      onTap: (){},
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.secondaryFixed, size: 20,),
                          const SizedBox(width: 10,),
                          Text('Clear conversations', style: TextStyle(color: Theme.of(context).colorScheme.secondaryFixed, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),)
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Visibility(
            visible: showShareDeleteAiChat,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPope) {
                switchShowDeleteAiChat();
              },
              child: Container(
                color: Colors.black54,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                    child: IntrinsicWidth(
                      child: IntrinsicHeight(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 45),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){},
                                      child: Row(
                                        children: [
                                          Icon(Icons.ios_share_outlined, color: Theme.of(context).colorScheme.tertiary, size: 20,),
                                          const SizedBox(width: 5,),
                                          Text('Share Conversation', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),)
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16,),
                                    GestureDetector(
                                      onTap: (){},
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.secondaryFixedDim, size: 20,),
                                          const SizedBox(width: 5,),
                                          Text('Delete Conversation', style: TextStyle(color: Theme.of(context).colorScheme.secondaryFixedDim, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      switchShowDeleteAiChat();
                                    },
                                    icon: const Icon(Icons.close, size: 14,),
                                  )
                              )
                            ],
                          )
                      ),
                    )
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
