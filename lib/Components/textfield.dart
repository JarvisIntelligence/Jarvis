import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.obscureText
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      enableSuggestions: false,
      autocorrect: false,
      obscureText: widget.obscureText,
      controller: widget.controller,
      cursorColor: const Color(0xFF979C9E),
      style: const TextStyle(
        color: Color(0xFF979C9E),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Color(0xFF979C9E),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.34, vertical: 8.32),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.32)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.32),
          borderSide: const BorderSide(
            color: Colors.white, // Border color when enabled
            width: 1, // Border thickness when enabled
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.32),
          borderSide: const BorderSide(
            color: Color(0xFF6b4eff), // Border color when focused
            width: 2.0, // Border thickness when focused
          ),
        ),
      ),
    );
  }
}
