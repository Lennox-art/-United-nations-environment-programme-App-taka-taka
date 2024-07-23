import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/theme/themes.dart';
import 'package:food/view/admin_page.dart';
import 'package:food/view/home_page.dart';
import 'package:food/view/profile_screen.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';

import 'new_post_screen.dart';
import 'notifications_screen.dart';


enum SuperPages {
  home("Home", Icons.home),
  notifications("Notifications", Icons.notifications),
  profile("Profile", Icons.person),
  admin("Admin", Icons.admin_panel_settings_outlined);

  final String value;
  final IconData icon;

  const SuperPages(this.value, this.icon);

  Widget get widget => switch(this) {
    SuperPages.home => const HomeTab(),
    SuperPages.notifications => NotificationsScreen(),
    SuperPages.profile => const ProfileScreen(),
    SuperPages.admin => AdminTab(),
  };

}

class SuperPageScreen extends StatefulWidget {
  const SuperPageScreen({super.key});

  @override
  _SuperPageScreenState createState() => _SuperPageScreenState();
}

class _SuperPageScreenState extends State<SuperPageScreen> {

  final FirestoreService store = getIt<FirestoreService>();
  SuperPages get _defaultPage => SuperPages.profile;
  late SuperPages _selectedPage = _defaultPage;
  late Future<List<SuperPages>> _pages;

  Future<List<SuperPages>> getUserData() async {
    List<SuperPages> tabsToShow = SuperPages.values.toList();

    try {

      debugPrint("Getting Auth data");
      var user = getIt<AuthService>().userNotifier.value;
      if(user == null) return tabsToShow..remove(SuperPages.admin);

      debugPrint("Getting User data");
      var userData = await store.getUserById(user.uid);
      if(userData == null) return tabsToShow..remove(SuperPages.admin);

      //Cache data
      store.currentUser.value = userData;
      debugPrint("ROLE ${userData.role.name}");

      if(userData.role != UserRoles.admin) return tabsToShow..remove(SuperPages.admin);

      return tabsToShow;
    } catch (e) {
      return tabsToShow..remove(SuperPages.admin);
    }
  }

  void _onItemTapped(SuperPages page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: <SuperPages> [_defaultPage],
      future: _pages,
      builder: (_, snap) {

        if(snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: LoadingIndicator()
          );
        }

        if(snap.hasError || !snap.hasData) {
          return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  setState(() {

                  });
                },
                child: const Icon(Icons.replay),
              ),
          );
        }

        List<SuperPages> pages = snap.requireData;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            title: ListTile(
              contentPadding: const EdgeInsets.all(0.0),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 6.0),
                child: Text('Taka Taka App',style: TextStyle(color: Colors.white)),
              ),
              subtitle:Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 3.0),
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
              child: const Icon(Icons.add),
            ) ,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: pages.map((p) {
              return BottomNavigationBarItem(
                icon: Icon(p.icon),
                label: p.value,
                backgroundColor: highlightBlue,
              );
            }).toList(),
            currentIndex: _selectedPage.index,
            onTap: (i) => _onItemTapped(pages[i]) ,
          ),
        );
      }
    );
  }

}