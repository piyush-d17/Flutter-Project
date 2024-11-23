import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/attendence/attendence_page.dart';
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
