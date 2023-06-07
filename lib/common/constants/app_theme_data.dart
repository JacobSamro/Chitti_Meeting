import 'package:flutter/material.dart';

ThemeData get appThemeData => ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color(0xff191919),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        //title Theme
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        //body Theme
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        //display Theme
        displayLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        displaySmall: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0),
        displayMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        //label Theme
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0),
      ),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      tabBarTheme: const TabBarTheme(indicatorColor: Colors.amber),
    );
