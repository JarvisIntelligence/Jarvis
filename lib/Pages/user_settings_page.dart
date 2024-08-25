import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  Future<void> logOut() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key:'user_data');
    InAppNotifications.show(
        description:
        'Account logged out successfully',
        onTap: () {}
    );
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, top: 50),
              child: Column(
                children: [
                  backHeader(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Column(
                      children: [
                        searchChatListBody(),
                        const SizedBox(
                          height: 20,
                        ),
                        settingOption(
                          Icon(Icons.notifications_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'Notifications',
                            (){}
                        ),
                        settingOption(
                          Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'Chat Settings',
                            (){
                            context.go('/homepage/usersettings/chatsettings');
                            }
                        ),
                        settingOption(
                            Icon(Icons.block_outlined, color: Theme.of(context).primaryColor, size: 20,),
                            'Blocked Contacts',
                              (){}
                        ),
                        settingOption(
                            Icon(Icons.star_outline, color: Theme.of(context).primaryColor, size: 20,),
                            'Starred Messages',
                                (){}
                        ),
                        settingOption(
                          Icon(Icons.language_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'App Language',
                          (){
                            context.push('/homepage/usersettings/applanguage');
                          }
                        ),
                        settingOption(
                          Icon(Icons.password_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'Change Password',
                            (){}
                        ),
                        settingOption(
                          Icon(Icons.payment_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'Billings and Payments',
                            (){}
                        ),
                        settingOption(
                          Icon(Icons.update_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'App Update',
                            (){}
                        ),
                        settingOption(
                          Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 20,),
                          'Help & Support',
                            (){
                              context.push('/homepage/usersettings/helpandsupportsettings');
                            }
                        ),
                        settingOption(
                          Icon(Icons.info_outlined, color: Theme.of(context).primaryColor, size: 20,),
                          'About',
                            (){
                              context.push('/homepage/usersettings/aboutsettings');
                            }
                        ),
                        settingOption(
                          const Icon(Icons.logout_outlined, color: Colors.red, size: 20,),
                          'Log Out',
                          logOut
                        ),
                        settingOption(
                            const Icon(Icons.delete_outlined, color: Colors.red, size: 20,),
                            'Delete Account',
                            logOut
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
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
          'Settings',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget settingOption(var icon, String value, Function() function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 20, top: 20),
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
            )
          ],
        ),
      ),
    );
  }

  Widget searchChatListBody() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary,
      ),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.search, color: Color(0xFFCDCFD0),),
          const SizedBox(width: 10,),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (a) {
              },
              // focusNode: _searchFocusNode,
              // controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.scrim, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              cursorColor: const Color(0xFF979C9E),
              decoration: const InputDecoration(hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF979C9E), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
