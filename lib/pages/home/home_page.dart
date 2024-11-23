import 'package:flutter/material.dart';
import '../location/location_page.dart'; // Import LocationPage for navigation

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Attendance'),
              onTap: () {
                Navigator.pushNamed(context, "/attendance");
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('Home Page')),
    );
  }
}

