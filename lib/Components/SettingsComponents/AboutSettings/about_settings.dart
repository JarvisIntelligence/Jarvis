import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutSettings extends StatefulWidget {
  const AboutSettings({super.key});

  @override
  State<AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends State<AboutSettings> {
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
                margin: const EdgeInsets.only(top: 20, bottom: 10, right: 20),
                child: Column(
                  children: [
                    settingOption(
                        Icon(Icons.attribution, color: Theme.of(context).primaryColor, size: 20,),
                        'Credits',
                         (){},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
          'About',
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
          ],
        ),
      ),
    );
  }
}
