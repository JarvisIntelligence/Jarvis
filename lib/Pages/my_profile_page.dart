import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  void onImageLoadFailed(error) {
    String errorMessage = '';
    if (error is SocketException) {
      errorMessage = 'Check your network connection. Profile Images failed to load';
    } else {
      errorMessage = 'Contact our customer service. Profile Images failed to load';
    }
    InAppNotifications.show(
        description: errorMessage,
        onTap: () {}
    );    // Place your function logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 50),
          child: Column(
            children: [
              backHeader(),
              const SizedBox(
                height: 20,
              ),
              profileImage(),
              credits(),
              userDetails(),
              // otherProfileOptions()
            ],
          ),
        )
      )
    );
  }

  Widget backHeader() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: Theme.of(context).colorScheme.scrim,
            )),
        Text(
          'Profile',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget profileImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Builder(
                    builder: (BuildContext context){
                      return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return PhotoView(
                                minScale: PhotoViewComputedScale.contained, // Ensure image is contained within the screen bounds
                                maxScale: PhotoViewComputedScale.covered * 2.0, // Adjust the maximum scale as needed
                                imageProvider: const NetworkImage('https://randomuser.me/api/portraits/men/30.jpg'),
                              );
                            }));
                          },
                          child: CachedNetworkImage(
                              imageUrl: 'https://randomuser.me/api/portraits/men/30.jpg',
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: imageProvider// Image radius
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[300],
                                  child: Lottie.asset('assets/lottie_animations/loading_animation.json')
                              ),
                              errorWidget: (context, url, error) {
                                onImageLoadFailed(error); // Call the function when image loading fails
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: const AssetImage('assets/icons/blank_profile.png'),
                                );
                              }
                          )
                      );
                    }
                ),
                Positioned(
                    bottom: 10,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_a_photo_rounded, size: 12, color: Theme.of(context).colorScheme.scrim,),
                      ),
                    )
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            width: 150,
            child: Text('Booty Slayer', style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400
            ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Text('@bootyslayer', style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400
          ),),
        ],
      )
    );
  }

  Widget credits() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Token', style: TextStyle(
              fontSize: 8,
              fontFamily: 'Inter',
              color: Theme.of(context).primaryColor
            ),),
          userDetail(
              Image.asset('assets/icons/coin_icon.png', width: 15, color: Theme.of(context).primaryColor,),
              'JarvisCoin',
              '200',
              'add',
              20
          ),
        ],
      ),
    );
  }

  Widget userDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Details', style: TextStyle(
              fontSize: 8,
              fontFamily: 'Inter',
              color: Theme.of(context).primaryColor
            ),
          ),
          userDetail(
              Icon(Icons.person, color: Theme.of(context).primaryColor, size: 15,),
              'Name',
              'Booty Slayer',
              'edit',
              15
          ),
          userDetail(
              Image.asset('assets/icons/at_icon.png', width: 15, color: Theme.of(context).primaryColor,),
              'Username',
              '@bootyslayer',
              'edit',
              15
          ),
          userDetail(
              Icon(Icons.email, color: Theme.of(context).primaryColor, size: 15,),
              'Email',
              'remi@gmail.com',
              'edit',
              15
          ),
          userDetail(
              Icon(Icons.notes, color: Theme.of(context).primaryColor, size: 15,),
              'Bio',
              'Passionate developer with a love for creating intuitive and dynamic user experiences. Enjoys exploring new technologies and continuously learning to stay ahead in the tech world. In my free time, you can find me hiking, reading sci-fi novels, or experimenting with new recipes in the kitchen.',
              'edit',
              15
          ),
        ],
      ),
    );
  }

  Widget userDetail(var icon, String title, String value, String iconButton, double iconButtonSize) {
    return Container(
      margin: EdgeInsets.only(bottom: (title != '') ? 5 : 5, top: (title != '') ? 10 : 5),
      child: Row(
        crossAxisAlignment: (title != '') ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: (title != '') ? 10 : 0),
            child: icon,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (title != '')
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (title == 'Email')
                    ? Row(
                      children: [
                        Text(title, style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w400
                        ),),
                        const SizedBox(
                          width: 3,
                        ),
                        Icon(Icons.verified, color: Theme.of(context).colorScheme.tertiary, size: 10,)
                      ],
                    )
                    : Text(title, style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w400
                    ),),
                    SizedBox(
                      width: (title != 'Bio') ? 150 : 200,
                      child: Text(value, style: TextStyle(
                          color: Theme.of(context).colorScheme.scrim,
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400
                      ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )
                  ],
                )
                : Text(value, style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                ),),
                IconButton(
                    onPressed: (){},
                    icon: Icon((iconButton == 'edit') ? Icons.edit : (iconButton == 'add') ? Icons.add : Icons.arrow_forward, size: iconButtonSize, color: Theme.of(context).colorScheme.tertiary,)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget otherProfileOptions() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10),
  //       color: const Theme.of(context).colorScheme.secondary,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('Messaging Options', style: TextStyle(
  //             fontSize: 8,
  //             fontFamily: 'Inter',
  //             color: Theme.of(context).primaryColor
  //         ),
  //         ),
  //         userDetail(
  //             const Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15,),
  //             '',
  //             'Starred Messages',
  //             'forward',
  //             15
  //         ),
  //         userDetail(
  //             const Icon(Icons.block, color: Theme.of(context).primaryColor, size: 15,),
  //             '',
  //             'Blocked Contacts',
  //             'forward',
  //             15
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
