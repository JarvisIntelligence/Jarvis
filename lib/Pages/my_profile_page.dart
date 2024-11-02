import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/friends.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/profile_user.dart';
import 'package:jarvis_app/Components/screen_loader.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

import '../Components/Utilities/BackendUtilities/upload_media_files.dart';
import '../Components/Utilities/camera.dart';
import '../Components/Utilities/extras.dart';

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
  OverlayEntry? overlayEntry;

  String name = '';
  String userName = '';
  String email = '';
  String bio = '';
  String coins = '0';
  String profileUrl = '';
  bool isDataLoading = true;

  bool progressVisible = false;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void dispose() {
    overlayEntry?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    init(); // Attempt to fetch data initially
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      if (!result.contains(ConnectivityResult.none)) {
        bool isConnected = await checkInternetConnection();
        if (isConnected) {
          init(); // Retry fetching data when connection is restored
        }
      }
    });
  }

  Future<void> init() async {
    await retrieveProfileDetails();
  }

  Future<void> retrieveProfileDetails() async {
    Map<String, dynamic> profileDetails = await ProfileUser().retrieveProfileDetails(
      await Extras().retrieveJWT(),
      await Extras().retrieveUserID(),
      false,
    );

    if (profileDetails.isEmpty || profileDetails['profile'] == null) {
      return;
    }

    if (mounted) {
      setState(() {
        name = profileDetails['profile']['fullname'] ?? '';
        userName = profileDetails['profile']['username'] ?? '';
        bio = profileDetails['profile']['biography'] ?? '';
        email = profileDetails['profile']['email'] ?? '';
        coins = profileDetails['profile']['jarviscoin']?.toString() ?? '0';
        isDataLoading = false;
        profileUrl = profileDetails['profile']['profilepicture'] ?? '';
      });
    }
  }

  Future<bool> checkInternetConnection() async {
    bool isNetworkOn = await InternetConnectionChecker().hasConnection;
    return isNetworkOn;
  }

  Future<Map<String, dynamic>> readJwtTokenAndID() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData;
    }
    return {};
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
    if (!progressVisible){
      showLoadingOverlay();
    } else {
      hideLoadingOverlay();
    }
    setState(() {
      progressVisible = !progressVisible;
    });
  }

  void showUploadImageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: uploadImageSheet(),
        );
      },
    );
  }

  void showLoadingOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: LoadingAnimation(progressVisible: progressVisible),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  void hideLoadingOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<void> uploadProfilePictureFromGallery () async {
    updateProgressVisible();
    Map<String, dynamic> mediaDetails = await Camera().getMediaFromFolder(true);
    Map<String, dynamic> userDetails = await readJwtTokenAndID();

    if (mediaDetails.isEmpty || mediaDetails['mediaType'] == 'Videos') {
      String message = mediaDetails.isEmpty
          ? 'Image upload failed. The upload process could not be completed.'
          : 'Image upload failed. Video files cannot be uploaded as a profile image.';

      InAppNotifications.show(description: message);
      updateProgressVisible();
      return;
    }

    String profileImageUrl = await UploadMediaFiles().uploadImage(mediaDetails['media']);
    bool uploadSuccess = await ProfileUser().updateProfileDetails(userDetails['jwt_token'], 'ProfilePicture', profileImageUrl);

    String notification = uploadSuccess
        ? 'Image upload successful. Your profile image has been changed.'
        : 'Image upload failed. The upload process could not be completed.';

    InAppNotifications.show(description: notification);

    if (!uploadSuccess) {
      updateProgressVisible();
      return;
    }

    setState(() {
      profileUrl = profileImageUrl;
    });
    Navigator.pop(context);
    updateProgressVisible();
  }

  Future<void> uploadProfilePictureFromCamera () async {
    updateProgressVisible();
    Map<String, dynamic> mediaDetails = await Camera().takeImageWithCamera(true);
    if(mediaDetails['name'] == 'Camera access denied. Please enable it in the app settings.'){
      InAppNotifications.show(description: 'Camera access denied. Please enable it in the app settings.');
      updateProgressVisible();
      return;
    }
    Map<String, dynamic> userDetails = await readJwtTokenAndID();

    String profileImageUrl = await UploadMediaFiles().uploadImage(mediaDetails['media']);
    bool uploadSuccess = await ProfileUser().updateProfileDetails(userDetails['jwt_token'], 'ProfilePicture', profileImageUrl);

    String notification = uploadSuccess
        ? 'Image upload successful. Your profile image has been changed.'
        : 'Image upload failed. The upload process could not be completed.';

    InAppNotifications.show(description: notification);

    if (!uploadSuccess) {
      updateProgressVisible();
      return;
    }

    setState(() {
      profileUrl = profileImageUrl;
    });
    Navigator.pop(context);
    updateProgressVisible();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, top: 50, bottom: 50),
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
                      onTap: () {
                        showUploadImageSheet(context);
                      },
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
                  updateProgressVisible();
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

  Widget uploadImageSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.transparent,
      height: 215,
      child: Column(
        children: [
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await uploadProfilePictureFromGallery();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.image, size: 20, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                          const SizedBox(
                            width: 15,
                          ),
                          Text('Choose from Gallery', style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontFamily: 'Inter',
                              fontSize: 12
                          ),)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: .5,
                    color: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await uploadProfilePictureFromCamera();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.camera, size: 20, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                          const SizedBox(
                            width: 15,
                          ),
                          Text('Capture Photo', style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontFamily: 'Inter',
                              fontSize: 12
                          ),)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
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
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.scrim,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400
              ),
            ),
          )
        ],
      ),
    );
  }

}
