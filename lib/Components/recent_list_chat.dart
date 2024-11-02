import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Utilities/extras.dart';
import 'cache_image.dart';

class RecentListChat extends StatefulWidget {
  const RecentListChat({super.key, required this.isGroup, required this.userImage,
    required this.userImage2, required this.name, required this.userName,
    required this.conversationId, required this.userImage3, required this.numberOfUsers,
    required this.groupImage, required this.isAddingGroup,
    required this.addingUsersToNewGroup(String name, String profileImage, int userIndex, String userId),
    required this.isUserSelected, required this.changeIsUserSelected,
    required this.userIndex, required this.userBio, required this.isPinned, required this.isArchived, required this.participantsId
  });

  final bool isGroup;
  final String userImage;
  final String userImage2;
  final String name;
  final String userName;
  final String conversationId;
  final String numberOfUsers;
  final String userImage3;
  final String groupImage;
  final String userBio;
  final bool isAddingGroup;
  final Function(String name, String profileImage, int userIndex, String userId) addingUsersToNewGroup;
  final Function() changeIsUserSelected;
  final bool isUserSelected;
  final int userIndex;
  final bool isPinned;
  final bool isArchived;
  final String participantsId;

  @override
  State<RecentListChat> createState() => _RecentListChatState();
}

class _RecentListChatState extends State<RecentListChat> {
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

  void startChat() {
    String userName = (widget.userName == '') ? '_' : widget.userName;
    // Define the base path
    String basePath = '/homepage/chat/${widget.name}/$userName/${widget.isGroup}';
    // Check conditions for encodedUserImage2 and encodedUserImage3
    String path;
    if (encodedUserImage2 == '') {
      path = '$basePath/$encodedUserImage/_/${widget.conversationId}';
    } else {
      path = '$basePath/$encodedUserImage/$encodedUserImage2/${widget.conversationId}';
    }
    // Append encodedUserImage3 if it's not empty
    if (encodedUserImage3 != '') {
      path = '$path/$encodedUserImage3';
    } else {
      path = '$path/_';
    }
    // Append the number of users at the end of the path
    path = '$path/${widget.numberOfUsers}/${widget.isPinned}/${widget.isArchived}/${widget.participantsId}';
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.isAddingGroup){
          startChat();
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        (widget.isGroup)
                            ? (widget.groupImage == '')
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
                        const SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Extras().capitalize(widget.name), style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 200,
                              child: Text(widget.userBio,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                              ),
                            ),
                            const SizedBox(height: 6,),
                          ],
                        )
                      ],
                    ),
                    Visibility(
                        visible: widget.isAddingGroup,
                        child: (widget.isUserSelected)
                            ? const Padding(
                          padding: EdgeInsets.only(right: 36),
                          child: Icon(Icons.check_circle, color: Colors.green,),
                        )
                            : Container(
                          width: 30.0, // Set the desired width
                          height: 30.0, // Set the height equal to width to make it circular
                          margin: const EdgeInsets.only(right: 33), // Set the desired margin
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2.0),
                          ),
                          child: IconButton(
                            onPressed: () {
                              widget.changeIsUserSelected();
                              widget.addingUsersToNewGroup(widget.name, widget.userImage, widget.userIndex, widget.participantsId);
                            },
                            icon: const Icon(Icons.add),
                            color: Theme.of(context).colorScheme.scrim, // Icon color
                            iconSize: 11.0, // Adjust the icon size as needed
                          ),
                        )
                    )
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 21, top: 15),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                height: 1,
              ),
            ),
          ],
        ),
      )
    );
  }
}
