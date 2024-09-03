import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/friends.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/profile_user.dart';
import 'package:jarvis_app/Components/screen_loader.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final storage = const FlutterSecureStorage();

  String name = '';
  String userName = '';
  String email = '';
  String bio = '';
  String coins = '0';
  String profileUrl = '';
  bool isDataLoading = true;

  bool progressVisible = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    Map<String, dynamic> userDetails = await readJwtTokenAndID();
    if (userDetails.isNotEmpty){
      Map<String, dynamic> profileDetails = await ProfileUser().retrieveProfileDetails(userDetails['jwt_token'], userDetails['userID'], false);
      setState(() {
        name = profileDetails['profile']['fullname'];
        userName = '${profileDetails['profile']['username']}';
        bio = profileDetails['profile']['biography'];
        email = profileDetails['profile']['email'];
        coins = profileDetails['profile']['jarviscoin'].toString();
        isDataLoading = false;
        profileUrl = profileDetails['profile']['profilepicture'] ?? '';
      });
    }
  }

  Future<Map<String, dynamic>> readJwtTokenAndID() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData;
    }
    return {};
  }

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

  void showEditProfileSheet(BuildContext context, String typeName, TextEditingController inputController, Function(String) onSave, String value) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: editProfileSheet(typeName, inputController, onSave, value),
        );
      },
    );
  }

  void updateProgressVisible() {
    setState(() {
      progressVisible = !progressVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  ],
                ),
              )
          ),
          LoadingAnimation(progressVisible: progressVisible,)
        ],
      )
    );
  }

  Widget shimmerPlaceholder(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainer,
      highlightColor: Theme.of(context).colorScheme.primary,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
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
                                imageProvider: NetworkImage(profileUrl),
                              );
                            }));
                          },
                          child: profileUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profileUrl,
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
                              : CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: const AssetImage('assets/icons/blank_profile.png'),
                              ),
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
          Container(
            constraints: const BoxConstraints(
              maxWidth: 150
            ),
            child: isDataLoading ? shimmerPlaceholder(80, 12) : Text(name, style: TextStyle(
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
          Visibility(
            visible: isDataLoading,
            child: const SizedBox(
              height: 5,
            )
          ),
          isDataLoading ? shimmerPlaceholder(60, 10) : Text('@$userName', style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400
          ),)
          ,
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
              coins,
              'add',
              20,
              null,
              (newValue){}
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
            name,
            'edit',
            15,
            nameController,
            (newValue) {
              setState(() {
                name = newValue;
              });
            },
          ),
          userDetail(
            Image.asset('assets/icons/at_icon.png', width: 15, color: Theme.of(context).primaryColor,),
            'Username',
            userName,
            'edit',
            15,
            usernameController,
            (newValue) {
              setState(() {
                userName = newValue;
              });
            },
          ),
          userDetail(
            Icon(Icons.email, color: Theme.of(context).primaryColor, size: 15,),
            'Email',
            email,
            'edit',
            15,
            emailController,
            (newValue) {
              setState(() {
                email = newValue;
              });
            },
          ),
          userDetail(
            Icon(Icons.notes, color: Theme.of(context).primaryColor, size: 15,),
            'Bio',
            bio,
            'edit',
            15,
            bioController,
            (newValue) {
              setState(() {
                bio = newValue;
              });
            },
          ),

        ],
      ),
    );
  }

  Widget userDetail(var icon, String title, String value, String iconButton, double iconButtonSize, TextEditingController? inputController, Function(String) onSave,) {
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
                Column(
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
                    Visibility(
                        visible: isDataLoading,
                        child: const SizedBox(
                          height: 5,
                        )
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: (title != 'Bio') ? 150 : 200
                      ),
                      child: isDataLoading ? shimmerPlaceholder((title != 'Bio') ? 80 : 200, 12) : Text((title == 'Username') ? '@$value' : value, style: TextStyle(
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
                ),
                Visibility(
                  visible: (title == 'Bio' || title == 'JarvisCoin') ? true : false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: IconButton(
                      onPressed: () {
                        if (inputController != null) {
                          showEditProfileSheet(context, title, inputController, onSave, value);
                        }
                      },
                      icon: Icon((iconButton == 'edit') ? Icons.edit : (iconButton == 'add') ? Icons.add : Icons.arrow_forward, size: iconButtonSize, color: Theme.of(context).colorScheme.tertiary,)
                  )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget editProfileSheet(String typeName, TextEditingController inputController, Function(String) onSave, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surface,
      height: 250, // Adjust height as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit $typeName',
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            maxLength: (typeName == 'Bio') ? 70 : null,
            buildCounter: (
                BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
              return Text(
                (typeName == 'Bio') ? '$currentLength / $maxLength' : '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              );
            },
            controller: inputController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              labelText: typeName,
              hintText: (typeName == 'Bio') ? 'Max number of characters allowed is 70' : '',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12,
                fontFamily: 'Inter',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              updateProgressVisible();
              if (inputController.text.isNotEmpty) {
                if(value == inputController.text){
                  InAppNotifications.show(
                    description: "Can't update. The $typeName still has the same value",
                    onTap: () {},
                  );
                  return;
                }
                Map<String, dynamic> jwtTokenAndID = await readJwtTokenAndID();
                String jwtToken = jwtTokenAndID['jwt_token'];
                bool ableToUpdateProfileOnline = await ProfileUser().updateProfileDetails(jwtToken, typeName, inputController.text);
                if (!ableToUpdateProfileOnline){
                  return;
                }
                onSave(inputController.text);
                inputController.text = '';
                InAppNotifications.show(
                  description: 'Your $typeName has been changed successfully',
                  onTap: () {},
                );
              }
              updateProgressVisible();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 35),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
