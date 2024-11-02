import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/ChangeNotifiers/new_message_notifier.dart';
import 'package:jarvis_app/Components/SettingsComponents/AboutSettings/about_settings.dart';
import 'package:jarvis_app/Components/SettingsComponents/AppLanguageSettings/app_language_settings.dart';
import 'package:jarvis_app/Components/SettingsComponents/ChatSettings/chat_settings.dart';
import 'package:jarvis_app/Components/SettingsComponents/HelpAndSupportSettings/help_and_support_settings.dart';
import 'package:jarvis_app/Components/SettingsComponents/HelpAndSupportSettings/reportBug.dart';
import 'package:jarvis_app/Components/archived_chats.dart';
import 'package:jarvis_app/Components/chat.dart';
import 'package:jarvis_app/Components/ChangeNotifiers/user_chat_list_change_notifier.dart';
import 'package:jarvis_app/Pages/add_new_users_page.dart';
import 'package:jarvis_app/Pages/login_page.dart';
import 'package:jarvis_app/Pages/my_profile_page.dart';
import 'package:jarvis_app/Pages/signup_page.dart';
import 'package:jarvis_app/Pages/home_page.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:jarvis_app/Pages/user_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Components/ChangeNotifiers/theme_provider_notifier.dart';
import 'Themes/dark_theme.dart';
import 'Themes/light_theme.dart';

late GoRouter router;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final bool isLoggedIn = await checkLoginStatus();
  await _precacheAssets();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserChatListChangeNotifier()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NewMessageNotifier())
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

Future<void> _precacheAssets() async {
  await Future.wait([
    precacheSvgPicture('assets/icons/ai_icon.svg'),
    precacheSvgPicture('assets/icons/logo.svg'),
    precacheSvgPicture('assets/icons/google.svg'),
    precacheSvgPicture('assets/icons/ai_logo.svg'),
    precacheSvgPicture('assets/icons/logo_name.svg'),
    precacheSvgPicture('assets/icons/push_pin_icon.svg'),
    precacheSvgPicture('assets/icons/push_pin_cancel_icon.svg'),
  ]);
}

Future precacheSvgPicture(String svgPath) async {
  final logo = SvgAssetLoader(svgPath);
  await svg.cache.putIfAbsent(logo.cacheKey(null), () => logo.loadBytes(null));
}

Future<void> precacheImageAsset(String imagePath) async {
  final image = AssetImage(imagePath);
  await precacheImage(image, WidgetsBinding.instance.rootElement!);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<bool> checkLoginStatus() async {
  const storage = FlutterSecureStorage();

  String? jsonString = await storage.read(key: 'user_data');
  if (jsonString != null) {

    return jsonDecode(jsonString)['isLogged'];
  } else {
    return false;
  }
}

_resetStyle() {
  InAppNotifications.instance
    ..titleFontSize = 10.0
    ..descriptionFontSize = 10.0
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
    router = _router;
  }

  GoRouter _configureRouter() {
    return GoRouter(
      initialLocation: widget.isLoggedIn ? '/homepage' : '/login',
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/signup',
          builder: (BuildContext context, GoRouterState state) {
            return const SignupPage();
          },
        ),
        GoRoute(
          path: '/homepage',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'chat/:name/:userName/:boolValue/:image1Value/:image2Value/:conversationId/:image3Value/:numberOfUsersValue/:isPinned/:isArchived/:participantsId',
              builder: (BuildContext context, GoRouterState state) {
                final String name = state.pathParameters['name']!;
                final String userName = state.pathParameters['userName']!;
                final String image1Value =
                Uri.decodeComponent(state.pathParameters['image1Value']!);
                final String image2Value =
                Uri.decodeComponent(state.pathParameters['image2Value']!);
                final String image3Value =
                Uri.decodeComponent(state.pathParameters['image3Value']!);
                final bool isGroup = state.pathParameters['boolValue'] == 'true';
                final String conversationId = state.pathParameters['conversationId']!;
                final String numberOfUsersValue = state.pathParameters['numberOfUsersValue']!;
                final bool isPinned = state.pathParameters['isPinned'] == 'true';
                final bool isArchived = state.pathParameters['isArchived'] == 'true';
                final String participantsId = state.pathParameters['participantsId']!;

                return Chat(
                  chatName: name,
                  userName: userName,
                  isGroup: isGroup,
                  userImage: image1Value,
                  userImage2: image2Value,
                  userImage3: image3Value,
                  conversationId: conversationId,
                  numberOfUsers: numberOfUsersValue,
                  isPinned: isPinned,
                  isArchived: isArchived,
                  participantsId: participantsId
                );
              },
            ),
            GoRoute(
              path: 'addnewusers',
              builder: (BuildContext context, GoRouterState state) {
                return const AddNewUsersPage();
              },
            ),
            GoRoute(
              path: 'myprofile',
              builder: (BuildContext context, GoRouterState state) {
                return const MyProfilePage();
              },
            ),
            GoRoute(
              path: 'usersettings',
              builder: (BuildContext context, GoRouterState state) {
                return const UserSettingsPage();
              },
              routes:  <RouteBase>[
                GoRoute(
                  path: 'chatsettings',
                  builder: (BuildContext context, GoRouterState state) {
                  return const ChatSettings();
                  },
                ),
                GoRoute(
                  path: 'aboutsettings',
                  builder: (BuildContext context, GoRouterState state) {
                    return const AboutSettings();
                  },
                ),
                GoRoute(
                  path: 'applanguage',
                  builder: (BuildContext context, GoRouterState state) {
                    return const AppLanguageSettings();
                  },
                ),
                GoRoute(
                  path: 'helpandsupportsettings',
                  builder: (BuildContext context, GoRouterState state) {
                    return const HelpAndSupportSettings();
                  },
                  routes:  <RouteBase>[
                    GoRoute(
                      path: 'reportbug',
                      builder: (BuildContext context, GoRouterState state) {
                        return const ReportBug();
                      },
                    ),
                  ]
                )
              ]
            ),
            GoRoute(
              path: 'archivedchats',
              builder: (BuildContext context, GoRouterState state) {
                return const ArchivedChats();
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}

