import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primaryColor: Colors.black,
  //brightness: Brightness.dark,
  backgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      color: Color(0xFF212121),
      iconTheme: IconThemeData(color: Colors.white)),
  scaffoldBackgroundColor: Colors.black,
  hintColor: Colors.white54,
  dividerColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.white),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    unselectedIconTheme: IconThemeData(color: Colors.white54),
    selectedIconTheme: IconThemeData(color: Colors.white),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white38),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),
  cardColor: Colors.grey[800],
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: Colors.white, brightness: Brightness.dark),
  textSelectionTheme:
      const TextSelectionThemeData(selectionColor: Colors.white54),
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  //brightness: Brightness.light,
  backgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(color: Colors.black),
      actionsIconTheme: IconThemeData(color: Colors.black),
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black)),
  scaffoldBackgroundColor: Colors.white,
  hintColor: Colors.black54,
  dividerColor: Colors.black54,
  iconTheme: const IconThemeData(color: Colors.black),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    unselectedIconTheme: IconThemeData(color: Colors.black38),
    selectedIconTheme: IconThemeData(color: Colors.black),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.black),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black45),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  ),
  cardColor: Colors.grey[500],
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: Colors.black, brightness: Brightness.light),
  textSelectionTheme:
      const TextSelectionThemeData(selectionColor: Colors.black38),
);

const kFontWeightBoldTextStyle = TextStyle(fontWeight: FontWeight.bold);
const kFontColorBlackTextStyle = TextStyle(color: Colors.black);
const kFontColorRedTextStyle = TextStyle(color: Colors.red);
const kFontColorGreyTextStyle = TextStyle(color: Colors.grey);
const kFontColorBlack54TextStyle = TextStyle(color: Colors.black54);
const kFontSize18TextStyle = TextStyle(fontSize: 18.0);
const kFontColorWhiteSize18TextStyle =
    TextStyle(color: Colors.white, fontSize: 18.0);
const kFontSize18FontWeight600TextStyle =
    TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
const kBillabongFamilyTextStyle =
    TextStyle(fontSize: 35.0, fontFamily: 'Billabong');
TextStyle kHintColorStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).hintColor);
}

const kBlueColorTextStyle = TextStyle(color: Colors.blue);
final Color kBlueColorWithOpacity = Colors.blue.withOpacity(0.8);
