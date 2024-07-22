import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    brightness: Brightness.dark,
    surface: const Color(0xFF202325), // a shade of black
    primary: const Color(0xFF6C7072), //darker grey
    secondary: const Color(0xFF303437), //lighter grey
    tertiary: const Color(0xFF6B4EFF), // a shade of purple
    scrim: const Color(0xFFE7E7FF), //my white
    secondaryContainer: const Color(0xFF090A0A), // a black
    onSecondaryContainer: const Color(0xFF979C9E),
    onPrimary: const Color(0xFFCDCFD0),
    primaryContainer: const Color(0x40ffffff),
    tertiaryContainer: const Color(0xFFE3E5E5),
    onTertiaryContainer: const Color(0xFF9783FF),
    onTertiary: const Color(0xFFABAFB1),
    tertiaryFixed: const Color(0xFFc0b5f9),
    tertiaryFixedDim: const Color(0x66FFFFFF),
    secondaryFixed: const Color(0xFFFFFFFF),
    secondaryFixedDim: const Color(0xFF9990FF),
    primaryFixed: const Color(0xFF5538EE)
  ),
  primaryColor: Colors.white38,
);