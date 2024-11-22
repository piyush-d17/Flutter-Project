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

class AttendancePage extends StatelessWidget {
  final List<Map<String, dynamic>> members = [
    {'name': 'John Doe', 'id': 1},
    {'name': 'Jane Smith', 'id': 2},
    {'name': 'Alice Johnson', 'id': 3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            title: Text(member['name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Details for ${member['name']}')),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPage(member: member),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
