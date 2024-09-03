import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/friends.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/register_login_user.dart';
import 'package:jarvis_app/Components/screen_loader.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../Components/Utilities/BackendUtilities/profile_user.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentPageIndex = 0;
  final _controller = PageController(
      initialPage: 0
  );

  final storage = const FlutterSecureStorage();
  bool progressVisible = false;

  final Map<String, dynamic> userRegisterJsonData = {};
  final Map<String, dynamic> userRegisteredData = {};

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void updateProgressVisible() {
    setState(() {
      progressVisible = !progressVisible;
    });
  }

  void validateEmailAddress() {
    if (_emailController.text.isEmpty) {
      InAppNotifications.show(
          description:
          'Email input field cannot be empty',
          onTap: () {}
      );
      return;
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
      InAppNotifications.show(
          description:
          'Email address is not in a valid format',
          onTap: () {}
      );
      return;
    }
    userRegisterJsonData['email'] = (_emailController.text).toLowerCase();
    _controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut
    );
  }

  Future<void> validateUserNameAndFullName() async {
    if(_usernameController.text.isEmpty || _fullNameController.text.isEmpty){
      InAppNotifications.show(
          description:
          'One or both input fields are empty',
          onTap: () {}
      );
      return;
    }
    userRegisterJsonData['username'] = (_usernameController.text).toLowerCase();
    userRegisterJsonData['fullname'] = _fullNameController.text;
    _controller.animateToPage(
        2,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut
    );
  }

  Future<String> retrieveJWT() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['jwt_token'];
    }
    return '';
  }

  Future<void> validatePassword() async {
    if (_passwordController.text.isEmpty){
      InAppNotifications.show(
          description:
          'Password input field is empty',
          onTap: () {}
      );
      return;
    } else{
      if(_passwordController.text != _confirmPasswordController.text){
        InAppNotifications.show(
            description:
            'Your confirm password does not match your password',
            onTap: () {}
        );
        return;
      }
    }
    bool isNetworkOn = await checkInternetConnection();
    if(isNetworkOn){
      FocusManager.instance.primaryFocus?.unfocus();
      userRegisterJsonData['password'] = _passwordController.text;
      signUp();
    }
  }

  Future<bool> checkInternetConnection() async {
    bool isNetworkOn = await InternetConnectionChecker().hasConnection;
    if(!isNetworkOn){
      InAppNotifications.show(
          description: "Please check your internet connection, you can't create an account at the moment",
          onTap: (){}
      );
    }
    return isNetworkOn;
  }

  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID']
  );

  Future<void> signUp() async {
    updateProgressVisible();
    Map<String, dynamic> userDetails = await RegisterLoginUser().registerAndCreateProfile(userRegisterJsonData);
    if(userDetails.isNotEmpty){
      await storeUserDetailsSecureStorage(userDetails['accessToken'], userDetails['userID']);
      updateProgressVisible();
      if (mounted) {
        context.go('/homepage');
      }
    } else{
      updateProgressVisible();
    }
  }

  Future<void> storeUserDetailsSecureStorage(String token, String userID) async {
    userRegisteredData['isLogged'] = true;
    userRegisteredData['userName'] = (_usernameController.text).toLowerCase();
    userRegisteredData['jwt_token']= token;
    userRegisteredData['userID'] = userID;

    String jsonString = jsonEncode(userRegisteredData);
    await storage.write(key: 'user_data', value: jsonString);
  }

  Future<Map<String, dynamic>?> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        // Get the Google authentication details
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Retrieve the idToken
        String? idToken = googleAuth.idToken;

        if (idToken != null) {
          Map<String, dynamic> userDetails = {
            'idToken': idToken,
            'photoUrl': googleUser.photoUrl
          };
          return userDetails;
        }
      }
    } catch (error) {
      InAppNotifications.show(
          description: "Error during Google sign-in: $error",
          onTap: (){}
      );
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop){
            if (_currentPageIndex == 0){
              context.pop();
            } else {
              _controller.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut
              );
            }
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100,),
                child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/logo.svg',
                          width: 118,
                          height: 48,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.scrim,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      SizedBox(
                        height: 385,
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPageIndex = page;
                            });
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            inputEmail(),
                            inputUserNameFullName(),
                            inputPassword()
                          ],
                        ),
                      ),
                      const SizedBox(height: 50,)
                    ]
                ),
              ),
              LoadingAnimation(progressVisible: progressVisible,)
            ],
          )
        )
    );
  }

  Widget inputEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text('Create an Account', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
          const SizedBox(height: 5,),
          Text('Enter your email to signup for this app', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
          const SizedBox(
            height: 30,
          ),
          CustomTextField(controller: _emailController, labelText: 'email@domain.com', obscureText: false, hintText: '',),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: validateEmailAddress,
              style: ButtonStyle(
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.32), // BorderRadius
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
              ),
              child: Text("Sign up with email", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      height: 1,
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
                ),
                Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      height: 1,
                    )
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () async {
                  await RegisterLoginUser().signInGoogleAuth(updateProgressVisible, handleGoogleSignIn, storeUserDetailsSecureStorage, context);
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.32), // BorderRadius
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.scrim),
                  fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                    ),
                    const SizedBox(width: 8.32,),
                    Text("Google", style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                  ],
                )
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: "If you already have an account ",
                style: const TextStyle(
                    color: Color(0xFF828282), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' Log in here',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle the tap
                        context.go('/login');
                        // You can navigate to the sign-up page or perform any action here
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'By clicking continue, you agree to our ',
                style: const TextStyle(color: Color(0xFF828282), fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, height: 1.3),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle the tap
                        // You can navigate to the sign-up page or perform any action here
                      },
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(color: Color(0xFF828282), fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle the tap
                        // You can navigate to the sign-up page or perform any action here
                      },
                  )
                ]
            ),
          ),
        ],
      ),
    );
  }

  Widget inputUserNameFullName() {
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut
                    );
                  },
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.scrim,),
                ),
              ),
            ),
            Text('Enter Personal Details', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30,),
              CustomTextField(controller: _usernameController, labelText: 'Username', obscureText: false, hintText: '',),
              const SizedBox(height: 20,),
              CustomTextField(controller: _fullNameController, labelText: 'Full Name', obscureText: false, hintText: '',),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateUserNameAndFullName,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.32), // BorderRadius
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                    fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                  ),
                  child: Text("Proceed", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget inputPassword() {
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut
                    );
                  },
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.scrim,),
                ),
              ),
            ),
            Text('Create Password', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30,),
              CustomTextField(controller: _passwordController, labelText: 'Enter Password', obscureText: true, hintText: '',),
              const SizedBox(height: 20,),
              CustomTextField(controller: _confirmPasswordController, labelText: 'Confirm Password', obscureText: true, hintText: '',),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validatePassword,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.32), // BorderRadius
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                    fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                  ),
                  child: Text("Finish", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
