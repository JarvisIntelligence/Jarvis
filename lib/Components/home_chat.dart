import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/cache_image.dart';

class HomeChat extends StatefulWidget {
  HomeChat({super.key,
    required this.notification, required this.userImage,
    required this.userImage2,
    required this.name, required this.lastMessage,
    required this.lastMessageTime, required this.isGroup,
    required this.id, required this.userImage3,
    required this.numberOfUsers, required this.groupImage,
    required this.toggleShowChatSelectedOptions
  });
  
  final bool notification;
  final bool isGroup;
  late String userImage;
  late String userImage2;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String id;
  final String userImage3;
  final String numberOfUsers;
  final String groupImage;
  final Function() toggleShowChatSelectedOptions;

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  late String encodedUserImage;
  late String encodedUserImage2;
  late String encodedUserImage3;

  @override
  void initState() {
    super.initState();
    encodedUserImage = Uri.encodeComponent(widget.userImage);
    encodedUserImage2 = Uri.encodeComponent(widget.userImage2);
    encodedUserImage3 = Uri.encodeComponent(widget.userImage3);
  }

  @override
  Widget build(BuildContext context) {
    final String lastMessageTimeString = DateFormat('h:mm a').format(widget.lastMessageTime);

    // Split the last message if it's a group chat
    String senderName = '';
    String actualMessage = widget.lastMessage;
    if (widget.isGroup) {
      List<String> messageParts = widget.lastMessage.split(':');
      if (messageParts.length > 1) {
        senderName = messageParts[0].trim();
        actualMessage = messageParts[1].trim();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5),
      child: GestureDetector(
        onTap: () async {
          // Define the base path
          String basePath = '/homepage/chat/${widget.name}/${widget.isGroup}';
          // Check conditions for encodedUserImage2 and encodedUserImage3
          String path;
          if (encodedUserImage2 == '') {
            path = '$basePath/$encodedUserImage/_/${widget.id}';
          } else {
            path = '$basePath/$encodedUserImage/$encodedUserImage2/${widget.id}';
          }
          // Append encodedUserImage3 if it's not empty
          if (encodedUserImage3 != '') {
            path = '$path/$encodedUserImage3';
          } else {
            path = '$path/_';
          }
          // Append the number of users at the end of the path
          path = '$path/${widget.numberOfUsers}';
          context.go(path);
        },
        onLongPress: () {
          widget.toggleShowChatSelectedOptions();
        },
        child: Column(
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
                          color: (widget.notification) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surface, // Change color as needed
                        ),
                      ),
                      const SizedBox(width: 10,),
                      (widget.isGroup)
                          ? (widget.groupImage != '')
                          ? (int.parse(widget.numberOfUsers) > 2)
                          ? SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 23, // Third image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage3, // Change this to the third user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 13, // Second image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage2, // Change this to the second user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 0, // First image position
                              child: CacheImage(
                                  imageUrl: widget.userImage, // Change this to the first user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                          ],
                        ),
                      )//Three people image
                          : SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -3,
                              top: -3,
                              child: CacheImage(
                                  imageUrl: widget.userImage,
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers),
                            ),
                            Positioned(
                              right: -3,
                              bottom: -3,
                              child: CacheImage(
                                imageUrl: widget.userImage2,
                                isGroup: widget.isGroup,
                                numberOfUsers: widget.numberOfUsers,),
                            ),
                          ],
                        ),
                      )//Two people image
                          : CacheImage(numberOfUsers: "1", imageUrl: widget.groupImage, isGroup: false,) //Load this if the group has a profile image
                          : CacheImage(numberOfUsers: widget.numberOfUsers, imageUrl: widget.userImage, isGroup: widget.isGroup,),
                      const SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                          const SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              if (widget.isGroup && senderName.isNotEmpty) ...[
                                Text(
                                  '$senderName: ',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                              Visibility(
                                visible: actualMessage == 'Image' || actualMessage == 'Video' || actualMessage == 'File',
                                child: Row(
                                  children: [
                                    Icon(
                                      (actualMessage == 'Image') ? Icons.image_outlined : (actualMessage == 'Video') ? Icons.video_camera_back_outlined : (actualMessage == 'File') ? Icons.insert_drive_file : null,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 5,),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Text(actualMessage,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4,),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(lastMessageTimeString, style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),),
                      const SizedBox(height: 5),
                      Visibility(
                          visible: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          maintainState: true,
                          child: SvgPicture.asset(
                            'assets/icons/push_pin_icon.svg',
                            height: 15,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSecondaryContainer,
                              BlendMode.srcIn,
                            ),
                          ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 21, top: 10),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

