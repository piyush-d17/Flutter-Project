import 'package:flutter/material.dart';

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
            ListTile(
              title: Text("home panel"),
              onTap: () => {
                Navigator.pushNamed(context, "/")
              },
            )
          ],
        ),
      ),
      body: Center(child: Text('Home Page')),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () => {},),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Chat')
      ],),
    );
  }
}

