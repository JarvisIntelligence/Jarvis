import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/friends.dart';
import 'package:jarvis_app/Components/Utilities/contact_list.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import '../Components/ChangeNotifiers/user_chat_list_change_notifier.dart';
import '../Components/Utilities/BackendUtilities/profile_user.dart';
import '../Components/Utilities/BackendUtilities/register_login_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Components/Utilities/BackendUtilities/send_receive_messages.dart';
import '../Components/Utilities/SqfliteHelperClasses/contact_list_database_helper.dart';
import '../Components/Utilities/SqfliteHelperClasses/initialize_database.dart';
import '../Components/Utilities/extras.dart';
import '../Components/screen_loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final storage = const FlutterSecureStorage();
  bool progressVisible = false;

  final Map<String, dynamic> userLogInJsonData = {};
  final Map<String, dynamic> userLoggedInData = {};

  final _controller = PageController(
      initialPage: 0
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID']
  );


  void updateProgressVisible() {
    setState(() {
      progressVisible = !progressVisible;
    });
  }

  Future<void> storeUserDetailsSecureStorage(String token, String userID) async {
    userLoggedInData['isLogged'] = true;
    userLoggedInData['userName'] = (_usernameController.text).toLowerCase();
    userLoggedInData['jwt_token'] = token;
    userLoggedInData['userID'] = userID;

    String jsonString = jsonEncode(userLoggedInData);
    await storage.write(key: 'user_data', value: jsonString);
  }

  Future<void> login() async {
    updateProgressVisible();
    userLogInJsonData['username'] = (_usernameController.text).toLowerCase();
    userLogInJsonData['password'] = _passwordController.text;

    Map<String, dynamic>? userDetails = await RegisterLoginUser().logInUser(userLogInJsonData, false);
    if(userDetails == null){
      updateProgressVisible();
      return;
    }
    String accessToken = userDetails['accessToken'];
    String userID = userDetails['userID'];

    await storeUserDetailsSecureStorage(accessToken, userID);
    updateProgressVisible();
    context.go('/homepage');
  }

  Future<bool> checkInternetConnection() async {
    bool isNetworkOn = await InternetConnectionChecker().hasConnection;
    if(!isNetworkOn){
      InAppNotifications.show(
          description: "Please check your internet connection, you can't log into your account at the moment",
          onTap: (){}
      );
    }
    return isNetworkOn;
  }

  Future<void> validateUsernameAndPassword() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty){
      InAppNotifications.show(
          description:
          'One or both input fields are empty',
          onTap: () {}
      );
    } else {
      bool isNetworkOn = await checkInternetConnection();
      if(isNetworkOn){
        FocusManager.instance.primaryFocus?.unfocus();
        login();
      }
    }
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
            'photoUrl': googleUser.photoUrl,
            'email': googleUser.email
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
        body: Stack(
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
                      height: 500,
                      child:  PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          loginScreen(),
                          forgotPasswordScreen()
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
    );
  }

  Widget loginScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text('Log Into Your Account', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
          const SizedBox(
            height: 30,
          ),
          CustomTextField(controller: _usernameController, labelText: 'Username', obscureText: false, hintText: '',),
          const SizedBox(
            height: 20,
          ),
          CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true, hintText: '',),
          const SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: 'Forgot Password?',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _controller.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut
                        );
                      },
                  ),
                )
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: validateUsernameAndPassword,
              style: ButtonStyle(
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.32), // BorderRadius
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
              ),
              child: Text("Log In", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
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
                text: "If you don't have an account ",
                style: const TextStyle(
                    color: Color(0xFF828282), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' Sign up here',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.go('/signup');
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

  Widget forgotPasswordScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    _controller.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut
                    );
                  },
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.scrim,),
                ),
              ),
              Text('Reset Your Password', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.scrim, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        PopScope(
          canPop: false,
          onPopInvoked: (didPop){
            _controller.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 30,),
                CustomTextField(controller: _emailController, labelText: 'email@domain.com', obscureText: false, hintText: '',),
                const SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool isNetworkOn = await checkInternetConnection();
                      if(isNetworkOn){
                        _controller.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut
                        );
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.32), // BorderRadius
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                      fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                    ),
                    child: Text("Reset", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
