import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

var highlightBlue = HexColor("#089de2");

var theme = ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme:  AppBarTheme(
      color: highlightBlue,
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        wordSpacing: 3.0,
      )
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: highlightBlue,
    unselectedItemColor: Colors.white,
    selectedItemColor: Colors.white,


  ),
  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 3.0,
          )
      )
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style:  ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      fixedSize: WidgetStatePropertyAll(Size(250, 30)),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(highlightBlue),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
      ),

    ),
  ),
);