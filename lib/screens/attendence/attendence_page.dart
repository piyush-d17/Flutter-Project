import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/location/location_page.dart';

class AttendancePage extends StatelessWidget {
  final List<Map<String, dynamic>> members = [
    {'name': 'Piyush Singh', 'id': 1},
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
