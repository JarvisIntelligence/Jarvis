import 'package:flutter/material.dart';
import 'cache_image.dart';

class RecentListChat extends StatefulWidget {
  const RecentListChat({super.key, required this.isGroup, required this.userImage,
    required this.userImage2, required this.name,
    required this.userImage3, required this.numberOfUsers,
    required this.groupImage, required this.isAddingGroup
  });

  final bool isGroup;
  final String userImage;
  final String userImage2;
  final String name;
  final String numberOfUsers;
  final String userImage3;
  final String groupImage;
  final bool isAddingGroup;

  @override
  State<RecentListChat> createState() => _RecentListChatState();
}

class _RecentListChatState extends State<RecentListChat> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

      },
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
                    Text(widget.name, style: const TextStyle(color: Color(0xFFE7E7FF), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'),),
                  ],
                ),
                Visibility(
                  visible: widget.isAddingGroup,
                  child: (isSelected)
                      ? const Padding(
                          padding: EdgeInsets.only(right: 35),
                          child: Icon(Icons.check_circle, color: Colors.green,),
                        )
                      : Container(
                          width: 60.0, // Set the desired width
                          height: 25.0,
                          margin: const EdgeInsets.only(right: 20),// Set the desired height
                          child: ElevatedButton(
                            onPressed: (){
                              setState(() {
                                isSelected =  !isSelected;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4EFF), // Set the background color to red
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0), // Adjust the border radius
                              ),
                            ),
                            child: const Text('Add', style: TextStyle(
                                color: Colors.white,
                                fontSize: 6,
                                fontFamily: 'Inter'
                            ),
                        ),
                      ),
                    )
                  )
                ],
              )
            ),
          Padding(
            padding: const EdgeInsets.only(left: 21, top: 15),
            child: Container(
              color: const Color(0xFF6C7072),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
