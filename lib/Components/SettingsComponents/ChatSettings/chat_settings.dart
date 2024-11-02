import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_app/Components/ChangeNotifiers/theme_provider_notifier.dart';
import 'package:provider/provider.dart';

class ChatSettings extends StatefulWidget {
  const ChatSettings({super.key});

  @override
  State<ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  final storage = const FlutterSecureStorage();

  String themeValue = 'Dark Mode';
  String radioThemeValue = 'Dark Mode';

  String fontValue = 'Medium';
  String radioFontValue = 'Medium';

  bool showChangeTheme = false;
  bool showChangeFontSize = false;
  List<String> themeModeOptions = ['System Default Mode', 'Dark Mode', 'Light Mode'];
  List<String> fontSizeOptions = ['Big', 'Medium', 'Small'];

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    String? themeModeValue = await storage.read(key: 'themeMode');
    String? fontSizeValue = await storage.read(key: 'fontSize');
    if (themeModeValue != null) {
      setState(() {
        themeValue = themeModeValue;
        radioThemeValue = themeModeValue;
      });
    }
    if (fontSizeValue != null) {
      setState(() {
        fontValue = fontSizeValue;
        radioFontValue = fontSizeValue;
      });
    }
  }

  Future<void> saveThemeChanges() async {
    if (radioThemeValue == 'System Default Mode') {
      Provider.of<ThemeProvider>(context, listen: false).setThemeSystem();
    } else {
      if(radioThemeValue == 'Light Mode') {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme('Light Mode');
      } else {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme('Dark Mode');
      }
    }
    await saveDataToStorage('themeMode', radioThemeValue);
    setState(() {
      themeValue = radioThemeValue;
      showChangeTheme = !showChangeTheme;
    });
  }

  Future<void> saveFontSizeChanges() async {
    if (radioFontValue == 'Big') {
      // Provider.of<ThemeProvider>(context, listen: false).setThemeSystem();
    } else {
      if(radioFontValue == 'Medium') {
        // Provider.of<ThemeProvider>(context, listen: false).toggleTheme('Light Mode');
      } else {
        // Provider.of<ThemeProvider>(context, listen: false).toggleTheme('Dark Mode');
      }
    }
    await saveDataToStorage('fontSize', radioFontValue);
    setState(() {
      fontValue = radioFontValue;
      showChangeFontSize = !showChangeFontSize;
    });
  }

  Future<void> saveDataToStorage(String key, String value) async {
    await storage.write(key: key, value: value);
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(top: 20, bottom: 10, right: 20),
                      child: Column(
                        children: [
                          settingOption(
                              Image.asset('assets/icons/theme_mode.png', width: 20, color: Theme.of(context).primaryColor,),
                              'Theme Mode',
                                  (){
                                    setState(() {
                                      showChangeTheme = !showChangeTheme;
                                    });
                                  },
                              themeValue
                          ),
                          settingOption(
                              Icon(Icons.format_size, color: Theme.of(context).primaryColor, size: 20,),
                              'Font Size',
                                  (){
                                    setState(() {
                                      showChangeFontSize = !showChangeFontSize;
                                    });
                                  },
                              fontValue
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ),
          changeTheme(
              () {
                setState(() {
                  showChangeTheme = !showChangeTheme;
                });
              },
            showChangeTheme,
            saveThemeChanges,
            themeModeOptions,
            radioThemeValue,
            'Change Theme Mode',
              (e) {
                setState(() {
                  radioThemeValue = e!;
                });
              }
          ),
          changeTheme(
              () {
                setState(() {
                  showChangeFontSize = !showChangeFontSize;
                });
              },
              showChangeFontSize,
              saveFontSizeChanges,
              fontSizeOptions,
              radioFontValue,
              'Change Font Size',
                  (e) {
                setState(() {
                  radioFontValue = e!;
                });
              }
          )
        ],
      )
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
          'Chat Settings',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget settingOption(var icon, String value, Function() function, String textValue) {
    return GestureDetector(
      onTap: function,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 20, top: 20,),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: icon,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: TextStyle(
                      color: Theme.of(context).colorScheme.scrim,
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400
                  ),),
                ],
              ),
            ),
            Text(
              textValue,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Theme.of(context).primaryColor,
                fontStyle: FontStyle.italic,
                fontSize: 10
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget changeTheme(Function() showChange,
        bool isShowChange, Function() saveChanges,
        List<String> options, String radioValue,
        String containerTitle, Function(String? e) changeRadioValue
      ) {
    return Visibility(
        visible: isShowChange,
        child: Stack(
          children: [
            GestureDetector(
              onTap: showChange,
              child: Container(
                color: Colors.black87,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: 250,
                height: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(containerTitle,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.scrim,
                          fontFamily: 'Inter',
                          fontSize: 12
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ...options.map((option) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.tertiary;
                          }
                          return Theme.of(context).colorScheme.scrim;
                        }),
                        title: Text(
                          option,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.scrim,
                              fontFamily: 'Inter',
                              fontSize: 10
                          ),
                        ),
                        value: option,
                        groupValue: radioValue,
                        onChanged: (value) {
                          changeRadioValue(value);
                        }
                    )),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveChanges,
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.32), // BorderRadius
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all(const Color(0xFF6b4eff)),
                          fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(42)),
                        ),
                        child: Text("Confirm Changes", style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                      ),
                    )
                  ],
                )
              ),
            )
          ],
        )
    );
  }
}
