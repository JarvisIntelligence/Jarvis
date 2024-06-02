import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';


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
  List<Map<String, dynamic>> userChatList = [
    {
      'notification': true,
      'id': '1',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': '2',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/cody_fisher.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': '3',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Fisher',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/cody_fisher.jpg',
    },
    {
      'notification': true,
      'id': '4',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen Yustiono',
      'lastMessage': "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': '5',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/jenifier_lopez.jpg',
      'name': 'Jennifer Lopez',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': '6',
      'userImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'name': 'Jessica Ramirez',
      'lastMessage': "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)",
      'lastMessageTime': DateTime.parse('2023-05-24T07:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': false,
      'id': '7',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/theresa_webb.jpg',
      'name': 'Theresa Webb',
      'lastMessage': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': false,
      'userImage2': '',
    },
    {
      'notification': true,
      'id': '8',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Angela',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T09:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/dianne_russell.jpg',
    },
    {
      'notification': true,
      'id': '9',
      'userImage': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/joe_smith.jpg',
      'name': 'Stephen & Theresa',
      'lastMessage': "There's no way you'll be able to jump your motorcycle over that bus.",
      'lastMessageTime': DateTime.parse('2023-05-24T22:24:00'),
      'isGroup': true,
      'userImage2': 'https://raw.githubusercontent.com/CodeDeveloper19/Images/main/FoodZero/AuthorImages/theresa_webb.jpg',
    }
  ];

  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();

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
          child: SingleChildScrollView(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              const Text('Create an Account', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
                              const SizedBox(height: 5,),
                              const Text('Enter your email to signup for this app', style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w400),),
                              const SizedBox(
                                height: 30,
                              ),
                              CustomTextField(controller: _emailController, labelText: 'email@domain.com', obscureText: false,),
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (){
                                    _controller.animateToPage(
                                        1,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut
                                    );
                                  },
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
                                            context.go('/auth/login');
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              const Text('Enter Personal Details', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
                              const SizedBox(height: 30,),
                              CustomTextField(controller: _usernameController, labelText: 'Username', obscureText: false),
                              const SizedBox(height: 20,),
                              CustomTextField(controller: _fullNameController, labelText: 'Full Name', obscureText: false),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (){
                                    _controller.animateToPage(
                                        2,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut
                                    );
                                  },
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              const Text('Create Password', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
                              const SizedBox(height: 30,),
                              CustomTextField(controller: _passwordController, labelText: 'Enter Password', obscureText: true),
                              const SizedBox(height: 20,),
                              CustomTextField(controller: _confirmPasswordController, labelText: 'Confirm Password', obscureText: true),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _secureStorageHelper.saveListData('userChatList', userChatList);
                                    context.go('/homepage');
                                  },
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50,)
                ]
            ),
          ),
        )
    );
  }
}
