import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/attendence/attendence_page.dart';
import 'screens/home/home_page.dart';

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
