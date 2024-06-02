import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/cache_image.dart';

class HomeChat extends StatefulWidget {
  HomeChat({super.key,
    required this.notification, required this.userImage,
    required this.userImage2,
    required this.name, required this.lastMessage,
    required this.lastMessageTime, required this.isGroup, required this.id});
  
  final bool notification;
  final bool isGroup;
  late String userImage;
  late String userImage2;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String id;

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  late String encodedUserImage;
  late String encodedUserImage2;

  @override
  void initState() {
    super.initState();
    encodedUserImage = Uri.encodeComponent(widget.userImage);
    encodedUserImage2 = Uri.encodeComponent(widget.userImage2);
  }


  @override
  Widget build(BuildContext context) {
    final String lastMessageTimeString = DateFormat('h:mm a').format(widget.lastMessageTime);

    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5),
      child: GestureDetector(
        onTap: () async {
          if (encodedUserImage2 == ''){
            context.go('/homepage/chat/${widget.name}/${widget.isGroup}/$encodedUserImage/_/${widget.id}'); //prevents a null value being passed to the route and thus making it not found
          } else {
            context.go('/homepage/chat/${widget.name}/${widget.isGroup}/$encodedUserImage/$encodedUserImage2/${widget.id}');
          }
        },
        child:  Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 11, // Adjust as needed
                        height: 11, // Adjust as needed
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (widget.notification) ? const Color(0xFF6B4EFF) : const Color(0xFF202325), // Change color as needed
                        ),
                      ),
                      const SizedBox(width: 10,),
                      (widget.isGroup)
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
                              child: CacheImage(imageUrl: widget.userImage, isGroup: widget.isGroup,),
                            ),
                            Positioned(
                              right: -3,
                              bottom: -3,
                              child: CacheImage(imageUrl: widget.userImage2, isGroup: widget.isGroup,),
                            ),
                          ],
                        ),
                      )
                          :
                      CacheImage(imageUrl: widget.userImage, isGroup: widget.isGroup,),
                      const SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 200,
                            child: Text(widget.lastMessage,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(color: Color(0xFFCDCFD0), fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(lastMessageTimeString, style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Inter'),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 21, top: 10),
              child: Container(
                color: const Color(0xFF6C7072),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

