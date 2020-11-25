import 'package:flutter/material.dart';
import 'view/home/page.dart';

void main() {
  runApp(StoryBoardApp());
}

class StoryBoardApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            primary: Colors.green,
          ))),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
