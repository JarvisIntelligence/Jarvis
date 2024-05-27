import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();


  final _controller = PageController(
      initialPage: 0
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF202325),
        body: SingleChildScrollView(
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
                  height: 500,
                  child:  PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            const Text('Log Into Your Account', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
                            const SizedBox(
                              height: 30,
                            ),
                            CustomTextField(controller: _usernameController, labelText: 'Username / Email', obscureText: false,),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true,),
                            const SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Forgot Password?',
                                      style: const TextStyle(
                                          color: Color(0xFF6B4EFF), fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
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
                                onPressed: (){
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
                                child: const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
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
                                  text: "If you don't have an account ",
                                  style: const TextStyle(
                                      color: Color(0xFF828282), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Sign up here',
                                      style: const TextStyle(
                                          color: Color(0xFF6B4EFF), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.go('/auth/signup');
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
                      Column(
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
                                    icon: const Icon(Icons.arrow_back, color: Colors.white,),
                                  ),
                                ),
                                const Text('Reset Your Password', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          PopScope(
                            canPop: false,
                            onPopInvoked: (didPop){
                              _controller.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  const SizedBox(height: 30,),
                                  CustomTextField(controller: _emailController, labelText: 'email@domain.com', obscureText: false),
                                  const SizedBox(height: 20,),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: (){
                                        _controller.animateToPage(
                                            0,
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
                                      child: const Text("Reset", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50,)
              ]
          ),
        )
    );
  }
}
