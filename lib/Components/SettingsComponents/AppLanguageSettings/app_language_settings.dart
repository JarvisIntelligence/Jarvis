import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppLanguageSettings extends StatefulWidget {
  const AppLanguageSettings({super.key});

  @override
  State<AppLanguageSettings> createState() => _AppLanguageSettingsState();
}

class _AppLanguageSettingsState extends State<AppLanguageSettings> {
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
          'App Languages',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
