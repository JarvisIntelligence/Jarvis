import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Pages/auth_page.dart';
import 'package:jarvis_app/Pages/login_page.dart';
import 'package:jarvis_app/Pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final GoRouter _router = GoRouter(
    initialLocation: '/auth',
    routes: <RouteBase>[
      GoRoute (
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginPage();
            },
          ),
          GoRoute(
            path: 'signup',
            builder: (BuildContext context, GoRouterState state) {
              return const SignupPage();
            },
          ),
        ]
      )
    ]
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
