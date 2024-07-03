import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jarvis_app/Components/Utilities/register_login_user.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';
import 'package:lottie/lottie.dart';

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
  // List<Map<String, dynamic>> userChatList = [
  //   {
  //     'notification': true,
  //     'id': '1',
  //     'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
  //     'name': 'John Doe',
  //     'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '2',
  //     'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
  //     'name': 'Emily Smith',
  //     'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '3',
  //     'userImage': 'https://randomuser.me/api/portraits/men/65.jpg',
  //     'name': 'Alex & Sophia',
  //     'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/women/68.jpg',
  //     'numberOfUsers': "2",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '4',
  //     'userImage': 'https://randomuser.me/api/portraits/men/12.jpg',
  //     'name': 'Michael Johnson',
  //     'lastMessage': "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '5',
  //     'userImage': 'https://randomuser.me/api/portraits/women/15.jpg',
  //     'name': 'Jennifer Lopez',
  //     'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '6',
  //     'userImage': 'https://randomuser.me/api/portraits/women/50.jpg',
  //     'name': 'Jessica Ramirez',
  //     'lastMessage': "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)",
  //     'lastMessageTime': DateTime.parse('2023-05-24T07:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '7',
  //     'userImage': 'https://randomuser.me/api/portraits/women/23.jpg',
  //     'name': 'Barbara Martinez',
  //     'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '8',
  //     'userImage': 'https://randomuser.me/api/portraits/men/18.jpg',
  //     'name': 'David & Angela',
  //     'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/women/19.jpg',
  //     'numberOfUsers': "2",
  //     'userImage3': '',
  //     'groupImage': 'https://picsum.photos/150'
  //   },
  //   {
  //     'notification': true,
  //     'id': '9',
  //     'userImage': 'https://randomuser.me/api/portraits/men/24.jpg',
  //     'name': 'Paul & Susan',
  //     'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T22:24:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/women/42.jpg',
  //     'numberOfUsers': "2",
  //     'userImage3': '',
  //     'groupImage': 'https://picsum.photos/150'
  //   },
  //   {
  //     'notification': false,
  //     'id': '10',
  //     'userImage': 'https://randomuser.me/api/portraits/men/10.jpg',
  //     'name': 'Kevin Brown',
  //     'lastMessage': "Did you see the game last night? It was amazing!",
  //     'lastMessageTime': DateTime.parse('2023-05-24T21:00:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '11',
  //     'userImage': 'https://randomuser.me/api/portraits/women/55.jpg',
  //     'name': 'Laura Wilson',
  //     'lastMessage': "Let's catch up soon! It's been too long.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T20:30:00'),
  //     'isGroup': false,
  //     'userImage2': 'https://randomuser.me/api/portraits/women/55.jpg',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '12',
  //     'userImage': 'https://randomuser.me/api/portraits/men/60.jpg',
  //     'name': 'Chris & Sam',
  //     'lastMessage': "Can we meet up for the project discussion?",
  //     'lastMessageTime': DateTime.parse('2023-05-24T18:45:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/men/62.jpg',
  //     'numberOfUsers': "2",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': false,
  //     'id': '13',
  //     'userImage': 'https://randomuser.me/api/portraits/women/22.jpg',
  //     'name': 'Natalie Adams',
  //     'lastMessage': "I can't believe it's already summer!",
  //     'lastMessageTime': DateTime.parse('2023-05-24T15:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '14',
  //     'userImage': 'https://randomuser.me/api/portraits/men/40.jpg',
  //     'name': 'Tom & Jerry',
  //     'lastMessage': "We should plan a road trip next month.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T14:24:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/men/42.jpg',
  //     'numberOfUsers': "2",
  //     'userImage3': '',
  //     'groupImage': 'https://picsum.photos/150'
  //   },
  //   {
  //     'notification': false,
  //     'id': '15',
  //     'userImage': 'https://randomuser.me/api/portraits/women/35.jpg',
  //     'name': 'Sophia Thompson',
  //     'lastMessage': "I'm baking cookies today. Want some?",
  //     'lastMessageTime': DateTime.parse('2023-05-24T13:24:00'),
  //     'isGroup': false,
  //     'userImage2': '',
  //     'numberOfUsers': "1",
  //     'userImage3': '',
  //     'groupImage': ''
  //   },
  //   {
  //     'notification': true,
  //     'id': '16',
  //     'userImage': 'https://randomuser.me/api/portraits/men/29.jpg',
  //     'name': 'James & Michael',
  //     'lastMessage': "Meet me at the park tomorrow.",
  //     'lastMessageTime': DateTime.parse('2023-05-24T12:24:00'),
  //     'isGroup': true,
  //     'userImage2': 'https://randomuser.me/api/portraits/men/31.jpg',
  //     'numberOfUsers': "3",
  //     'userImage3': 'https://randomuser.me/api/portraits/lego/1.jpg',
  //     'groupImage': ''
  //   },
  // ];

  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();
  final storage = const FlutterSecureStorage();
  bool progressVisible = false;

  final Map<String, dynamic> userRegisterJsonData = {};
  final Map<String, dynamic> userRegisteredData = {};

  @override
  void initState() {
    super.initState();
  }

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

  void validateUserNameAndFullName() {
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

  Future<void> signUp() async {
    updateProgressVisible();
    Future<bool> isRegisterSuccessful= RegisterLoginUser().registerUser(userRegisterJsonData);
    if(await isRegisterSuccessful){
      await _secureStorageHelper.saveListData('userChatList', []);
      await storeUserDetailsSecureStorage();
      updateProgressVisible();
      if (mounted) {
        context.go('/homepage');
      }
    } else{
      updateProgressVisible();
    }
  }

  Future<void> storeUserDetailsSecureStorage() async {
    userRegisteredData['isLogged'] = true;
    userRegisteredData['userName'] = (_usernameController.text).toLowerCase();
    userRegisteredData['fullName'] = _fullNameController.text;

    String jsonString = jsonEncode(userRegisteredData);
    await storage.write(key: 'user_data', value: jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF202325),
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
              loadingAnimation()
            ],
          )
        )
    );
  }

  Widget loadingAnimation() {
    return Visibility(
      visible: progressVisible,
      child: Container(
        color: Colors.black87,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Lottie.asset('assets/lottie_animations/loading_animation.json', width: 80),
        ),
      )
    );
  }

  Widget inputEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Text('Create an Account', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
          const SizedBox(height: 5,),
          const Text('Enter your email to signup for this app', style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
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
                backgroundColor: WidgetStateProperty.all(const Color(0xFF6b4eff)),
                fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
              ),
              child: const Text("Sign up with email", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
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
                      color: const Color(0xFFCDCFD0),
                      height: 1,
                    )
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with', style: TextStyle(color: Color(0xFF979C9E), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
                ),
                Expanded(
                    child: Container(
                      color: const Color(0xFFCDCFD0),
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
                onPressed: (){},
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.32), // BorderRadius
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                    ),

                    const SizedBox(width: 8.32,),
                    const Text("Google", style: TextStyle(color: Color(0xFF404446), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
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
                    style: const TextStyle(
                        color: Color(0xFF6B4EFF), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
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
                    style: const TextStyle(color: Color(0xFF6B4EFF), fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
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
                    style: const TextStyle(color: Color(0xFF6B4EFF), fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),
              ),
            ),
            const Text('Enter Personal Details', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
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
                    backgroundColor: WidgetStateProperty.all(const Color(0xFF6b4eff)),
                    fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                  ),
                  child: const Text("Proceed", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),
              ),
            ),
            const Text('Create Password', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
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
                    backgroundColor: WidgetStateProperty.all(const Color(0xFF6b4eff)),
                    fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                  ),
                  child: const Text("Finish", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
