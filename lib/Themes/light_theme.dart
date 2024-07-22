import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    brightness: Brightness.light,
    surface: const Color(0xFFE0E0E0), // light grey
    primary: const Color(0xFFB3B3B3), // slightly darker light grey
    secondary: const Color(0xFFA6A6A6), // even darker light grey
    tertiary: const Color(0xFF6B4EFF), // a shade of purple
    scrim: const Color(0xFF3C3C44), // darker shade for scrim
    secondaryContainer: const Color(0xFFD0D0D0), // a darker light grey
    onSecondaryContainer: const Color(0xFF4A4F51), // darker grey
    onPrimary: const Color(0xFF6C6C6C), // a medium grey
    primaryContainer: const Color(0x403C3C3C), // semi-transparent dark grey
    tertiaryContainer: const Color(0xFFC0C0C0), // a medium-light grey
    onTertiaryContainer: const Color(0xFF6C4DFF), // a deeper shade of purple
    onTertiary: const Color(0xFF7D7D7D), // a medium grey
    tertiaryFixed: const Color(0xFF9B8BF4), // a medium-light purple
    tertiaryFixedDim: const Color(0x66CCCCCC), // semi-transparent light grey
    secondaryFixed: const Color(0xFF000000),
    secondaryFixedDim: const Color(0xFF7A6BEF), // a medium purple
    primaryFixed: const Color(0xFF5538EE)
  ),
  primaryColor: Colors.black38, // semi-transparent black equivalent
);