import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/chat.dart';
import 'package:jarvis_app/Pages/auth_page.dart';
import 'package:jarvis_app/Pages/login_page.dart';
import 'package:jarvis_app/Pages/signup_page.dart';
import 'package:jarvis_app/Pages/home_page.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

_resetStyle() {
  InAppNotifications.instance
    ..titleFontSize = 14.0
    ..descriptionFontSize = 14.0
    ..textColor = Colors.white
    ..backgroundColor = const Color(0xFF5538EE)
    ..shadow = true
    ..animationStyle = InAppNotificationsAnimationStyle.scale;
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _resetStyle();
    _router = _configureRouter();
  }

  GoRouter _configureRouter() {
    return GoRouter(
      initialLocation: '/auth',
      routes: <RouteBase>[
        GoRoute(
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
          ],
        ),
        GoRoute(
          path: '/homepage',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'chat/:name/:boolValue/:image1Value/:image2Value/:id',
              builder: (BuildContext context, GoRouterState state) {
                final String name = state.pathParameters['name']!;
                final String image1Value =
                Uri.decodeComponent(state.pathParameters['image1Value']!);
                final String image2Value =
                Uri.decodeComponent(state.pathParameters['image2Value']!);
                final bool isGroup = state.pathParameters['boolValue'] == 'true';
                final String id = state.pathParameters['id']!;
                return Chat(
                  chatName: name,
                  isGroup: isGroup,
                  userImage: image1Value,
                  userImage2: image2Value,
                  id: id
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: InAppNotifications.init(),
    );
  }
}

