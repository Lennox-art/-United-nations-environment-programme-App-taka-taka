import 'package:flutter/material.dart';
import 'package:food/view/home_page.dart';
import 'package:food/view/profile_screen.dart';

import 'new_post_screen.dart';
import 'notifications_screen.dart';


class SuperPageScreen extends StatefulWidget {
  @override
  _SuperPageScreenState createState() => _SuperPageScreenState();
}

class _SuperPageScreenState extends State<SuperPageScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePageScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taka Taka App'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPostScreen()),
          );
        },
        child: Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}