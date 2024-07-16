import 'package:flutter/material.dart';
import 'package:food/view/home_page.dart';
import 'package:food/view/profile_screen.dart';

import 'new_post_screen.dart';
import 'notifications_screen.dart';


enum SuperPages {
  home("Home", Icons.home),
  notifications("Notifications", Icons.notifications),
  profile("Profile", Icons.person);

  final String value;
  final IconData icon;

  const SuperPages(this.value, this.icon);

  Widget get widget => switch(this) {
    SuperPages.home => const HomeTab(),
    SuperPages.notifications => NotificationsScreen(),
    SuperPages.profile => ProfileScreen(),
  };

}

class SuperPageScreen extends StatefulWidget {
  @override
  _SuperPageScreenState createState() => _SuperPageScreenState();
}

class _SuperPageScreenState extends State<SuperPageScreen> {


  SuperPages get _defaultPage => SuperPages.home;
  late SuperPages _selectedPage = _defaultPage;
  List<SuperPages> pages = SuperPages.values;


  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = pages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text('Taka Taka App',style: TextStyle(color: Colors.white)),
          subtitle: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(_selectedPage.value, style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
      body: _selectedPage.widget,
      floatingActionButton: Visibility(
        visible: _selectedPage == SuperPages.home,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewPostScreen()),
            );
          },
          child: Icon(Icons.add),
        ) ,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: SuperPages.values.map((p) {
          return BottomNavigationBarItem(
            icon: Icon(p.icon),
            label: p.value,
          );
        }).toList(),
        currentIndex: _selectedPage.index,
        onTap: _onItemTapped,
      ),
    );
  }
}