import 'package:flutter/material.dart';
import 'package:jarvis_app/Components/Utilities/password_strength_checker.dart';
import 'package:jarvis_app/Components/password_strength_indicator.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.hintText,
    this.focusNode,

  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String hintText;
  final FocusNode? focusNode;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool isObscured;
  late FocusNode _focusNode;

  String indicatorText = '';
  Color indicatorColor = Colors.transparent;
  int numberOfIndicator = 0;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode(); // Use provided focusNode or create a new one
    if (widget.focusNode == null) {
      _focusNode.addListener(() {
        setState(() {}); // Update the UI when the focus changes
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            TextField(
              onChanged: (text) {
                if(widget.controller.text.isNotEmpty && widget.labelText == 'Enter Password'){
                  setState(() {
                    indicatorText = PasswordStrengthChecker().calculatePasswordStrength(widget.controller.text);
                    indicatorColor = PasswordStrengthChecker().getIndicatorColor(indicatorText);
                    numberOfIndicator = PasswordStrengthChecker().getNumberOfIndicator(indicatorText);
                  });
                }
              },
              enableSuggestions: (widget.hintText == 'Add using their username' ) ? true : false,
              autocorrect: false,
              obscureText: isObscured,
              controller: widget.controller,
              cursorColor: Theme.of(context).colorScheme.onSecondaryContainer,
              focusNode: _focusNode,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.only(
                    left: 16.34,
                    right: (widget.labelText == 'Password') ? 45 : 16.34,
                    top: 8.32,
                    bottom: 8.32
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.32)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.32),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.scrim, // Border color when enabled
                    width: 1, // Border thickness when enabled
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.32),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, // Border color when focused
                    width: 2.0, // Border thickness when focused
                  ),
                ),
              ),
            ),
            Visibility(
              visible: (widget.labelText == 'Enter Password' && widget.controller.text.isNotEmpty) ? true : false,
              child: PasswordStrengthIndicator(
                indicatorText: indicatorText,
                indicatorColor: indicatorColor,
                numberOfIndicator: numberOfIndicator,
              ),
            ),
          ],
        ),
        Visibility(
          visible: widget.labelText.contains('Password') ? true : false,
          child: Positioned(
            right: 0,
            child: IconButton(
              onPressed: (){
                setState(() {
                  isObscured = !isObscured;
                });
              },
              icon: (isObscured) ? Icon(Icons.visibility_off, size: 18, color: Theme.of(context).colorScheme.scrim,) : Icon(Icons.visibility, size: 18, color: Theme.of(context).colorScheme.scrim,),
            ),
          )
        )
      ],
    );
  }
}
