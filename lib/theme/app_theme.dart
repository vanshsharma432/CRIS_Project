import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AColors.primary,
  scaffoldBackgroundColor: AColors.offWhite,
  cardColor: AColors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: AColors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: AColors.black),
    titleTextStyle: TextStyle(
      color: AColors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: AColors.primary,
    secondary: AColors.secondary,
    error: AColors.error,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(AColors.primary),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AColors.paleCyan),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AColors.primary),
    ),
    hintStyle: TextStyle(color: AColors.gray, fontSize: 14),
    labelStyle: TextStyle(color: AColors.textSecondary),
  ),
);
