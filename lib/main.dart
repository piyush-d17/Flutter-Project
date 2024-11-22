import 'package:flutter/material.dart';
import 'pages/home/home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => HomePage(),
        "/attendance": (context) => AttendancePage(),
      },
    );
  }
}

void main() {
  runApp(MyApp());
}
