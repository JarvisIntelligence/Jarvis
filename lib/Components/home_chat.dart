import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/cache_image.dart';

import 'Utilities/extras.dart';

class HomeChat extends StatefulWidget {
  HomeChat({super.key,
    required this.notification, required this.userImage,
    required this.userImage2,
    required this.name, required this.userName, required this.lastMessage,
    required this.lastMessageTime, required this.isGroup,
    required this.conversationId, required this.userImage3,
    required this.numberOfUsers, required this.groupImage,
    required this.increaseDecreaseNumberOfSelectedChats,
    required this.isPinned, required this.isArchived, required this.isChatSelected,
    required this.changeIsChatSelected, required this.addChatToDataMap,
    required this.removeChatFromDataMap, required this.participantsId,
    required this.encodedUserImage, required this.encodedUserImage2, required this.encodedUserImage3
  });
  
  final bool notification;
  final bool isGroup;
  late String userImage;
  late String userImage2;
  final String name;
  final String userName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String conversationId;
  final String userImage3;
  final String numberOfUsers;
  final String groupImage;
  final Function(String increaseOrDecrease) increaseDecreaseNumberOfSelectedChats;
  final bool isPinned;
  final bool isArchived;
  final bool isChatSelected;
  final Function() changeIsChatSelected;
  final Function() addChatToDataMap;
  final Function() removeChatFromDataMap;
  final String participantsId;
  final String encodedUserImage;
  final String encodedUserImage2;
  final String encodedUserImage3;


  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {

  String getFormattedLastMessageTime(DateTime lastMessageTime) {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime).inDays;

    if (difference == 0) {
      return DateFormat('h:mm a').format(lastMessageTime);
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(lastMessageTime);
    }
  }


  @override
  Widget build(BuildContext context) {
    final String lastMessageTimeString = getFormattedLastMessageTime(widget.lastMessageTime!);

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

    return GestureDetector(
      onTap: () async {
        String userName = (widget.userName == '') ? '_' : widget.userName;
        // Define the base path
        String basePath = '/homepage/chat/${widget.name}/$userName/${widget.isGroup}';
        // Check conditions for encodedUserImage2 and encodedUserImage3
        String path;
        if (widget.encodedUserImage2 == '') {
          path = '$basePath/${widget.encodedUserImage}/_/${widget.conversationId}';
        } else {
          path = '$basePath/${widget.encodedUserImage}/${widget.encodedUserImage2}/${widget.conversationId}';
        }
        // Append encodedUserImage3 if it's not empty
        if (widget.encodedUserImage3 != '') {
          path = '$path/${widget.encodedUserImage3}';
        } else {
          path = '$path/_';
        }
        // Append the number of users, isPinned, and isArchived at the end of the path
        path = '$path/${widget.numberOfUsers}/${widget.isPinned}/${widget.isArchived}/${widget.participantsId}';
        context.go(path);
      },
      onLongPress: () {
        if(widget.isChatSelected) {
          widget.increaseDecreaseNumberOfSelectedChats('decrease');
          widget.removeChatFromDataMap();
        } else {
          widget.increaseDecreaseNumberOfSelectedChats('increase');
          widget.addChatToDataMap();
        }
        widget.changeIsChatSelected();
      },
      child: Container(
        color: (widget.isChatSelected) ? Theme.of(context).colorScheme.surfaceContainer : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, top: 15),
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
                            color: (widget.notification) ? Theme.of(context).colorScheme.tertiary : (widget.isChatSelected) ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        (widget.isGroup)
                            ? (widget.groupImage.isEmpty)
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
                            Text(Extras().capitalize(widget.name), style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
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
                                Container(
                                  width: MediaQuery.of(context).size.width - 280,
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
                        Text((widget.lastMessage == '') ? '' : lastMessageTimeString, style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),),
                        const SizedBox(height: 5),
                        Visibility(
                          visible: widget.isPinned,
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
      ),
    );
  }
}

