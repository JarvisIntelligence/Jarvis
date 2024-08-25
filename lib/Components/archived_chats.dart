import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArchivedChats extends StatefulWidget {
  const ArchivedChats({super.key});

  @override
  State<ArchivedChats> createState() => _ArchivedChatsState();
}

class _ArchivedChatsState extends State<ArchivedChats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 50),
          child: Column(
            children: [
              backHeader()
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
          'Archived Chats',
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
