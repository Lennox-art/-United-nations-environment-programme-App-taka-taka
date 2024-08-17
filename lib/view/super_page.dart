import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/routes/routes.dart';
import 'package:food/theme/themes.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';

enum SuperPages {
  timeline("Timeline", FontAwesomeIcons.barsStaggered, Routes.timeline),
  wasteEstimation(
      "Waste estimation", FontAwesomeIcons.dumpster, Routes.wasteEstimation),
  newPost("New post", FontAwesomeIcons.plus, Routes.newPost),
  adminNewPost("New post", FontAwesomeIcons.plus, Routes.adminNewPost),
  mvp("Most voted posts", FontAwesomeIcons.medal, Routes.mvp),
  profile("Profile", Icons.person, Routes.profile),
  notifications("Notifications", Icons.notifications, Routes.notifications),
  users("Users", FontAwesomeIcons.userGear, Routes.users);

  final String value;
  final IconData icon;
  final Routes route;

  const SuperPages(this.value, this.icon, this.route);

  static List<SuperPages> get adminPages => [
        SuperPages.timeline,
        SuperPages.wasteEstimation,
        SuperPages.mvp,
        SuperPages.adminNewPost,
        SuperPages.profile,
        SuperPages.notifications,
        SuperPages.users,
      ];

  static List<SuperPages> get userPages => [
        SuperPages.timeline,
        SuperPages.wasteEstimation,
        SuperPages.newPost,
        SuperPages.profile,
        SuperPages.notifications,
      ];
}

class SuperPageScreen extends StatefulWidget {
  const SuperPageScreen({super.key});

  @override
  _SuperPageScreenState createState() => _SuperPageScreenState();
}

class _SuperPageScreenState extends State<SuperPageScreen> {
  final FirestoreService store = getIt<FirestoreService>();

  SuperPages get _defaultPage => SuperPages.timeline;
  late SuperPages _selectedPage = _defaultPage;
  late Future<List<SuperPages>> _pages;
  final FirestoreService _firestore = getIt<FirestoreService>();
  final AuthService _authService = getIt<AuthService>();

  Future<List<SuperPages>> getUserData() async {
    try {
      debugPrint("Getting Auth data");
      var user = getIt<AuthService>().userNotifier.value;
      if (user == null) return SuperPages.userPages;

      debugPrint("Getting User data");
      var userData = await store.getUserById(user.uid);
      if (userData == null) return SuperPages.userPages;

      //Cache data
      store.currentUser.value = userData;
      debugPrint("ROLE ${userData.role.name}");

      if (userData.role != UserRoles.admin) {
        return SuperPages.userPages;
      }

      return SuperPages.adminPages;
    } catch (e) {
      return SuperPages.userPages;
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
      initialData: <SuperPages>[_defaultPage],
      future: _pages,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingIndicator());
        }

        if (snap.hasError || !snap.hasData) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Icon(Icons.replay),
            ),
          );
        }

        List<SuperPages> pages = snap.requireData;

        return ValueListenableBuilder(
          valueListenable: _firestore.currentUser,
          builder: (_, user, __) {
            return Scaffold(
              appBar: AppBar(
                  title: const Text("Taka Taka App"),
              ),
              body: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: user?.photoUrl != null,
                          replacement: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          child: CircularPhoto(
                            radius: 60,
                            url: user?.photoUrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome!',
                                style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text(
                                  user?.displayName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.waving_hand,
                                    color: Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      itemCount: pages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 30.0,
                        mainAxisExtent: 100.0,
                      ),
                      itemBuilder: (_, i) {
                        SuperPages page = pages[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              page.route.path,
                            );
                          },
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(page.icon, color: highlightBlue,),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(page.value),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
