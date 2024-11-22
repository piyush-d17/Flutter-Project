import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  final Map<String, dynamic> member;

  LocationPage({required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location for ${member['name']}')),
      body: Center(
        child: Text(
          'Map showing current location and route for ${member['name']}',
        ),
      ),
    );
  }
}
