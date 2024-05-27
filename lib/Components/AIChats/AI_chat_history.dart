import 'package:flutter/material.dart';
import 'package:jarvis_app/Components/AIChats/previous_ai_chat.dart';

class AiChatHistory extends StatefulWidget {
  const AiChatHistory({super.key});

  @override
  State<AiChatHistory> createState() => _AiChatHistoryState();
}

class _AiChatHistoryState extends State<AiChatHistory> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202325),
      padding: const EdgeInsets.only(top: 70, right: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF6C7072),
              ),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.search, color: Color(0xFFCDCFD0),),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                      cursorColor: const Color(0xFF979C9E),
                      decoration: const InputDecoration(hintText: 'Search...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF979C9E), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PreviousAiChat(chatName: 'New Chat', isNewChat: true), //Should be permanently fixed,
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PreviousAiChat(chatName: 'Why is the sky blue?', isNewChat: false),
                  PreviousAiChat(chatName: 'Why am I broke ?', isNewChat: false),
                  PreviousAiChat(chatName: 'Will Jarvis make money?', isNewChat: false),
                  PreviousAiChat(chatName: 'Crazy right ?', isNewChat: false)
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
                  color: const Color(0x66FFFFFF),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 60, top: 30),
                child: GestureDetector(
                  onTap: (){},
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 20,),
                      SizedBox(width: 10,),
                      Text('Clear conversations', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),)
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
