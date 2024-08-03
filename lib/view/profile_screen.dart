import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/routes/routes.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = getIt<AuthService>();
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    String? id = _authService.userNotifier.value?.uid;
    if (id == null) {
      return const Text("User not logged in");
    }



    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _firestoreService.currentUser,
              builder: (_, user, __) {
                if (user == null) {
                  return const Text("No user data");
                }

                return Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularPhoto(
                                url: user.photoUrl,
                              ),
                              Builder(
                                builder: (context) {
                                  return ListTile(
                                    title: Text(
                                      user.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  _authService.userNotifier.value?.email ??
                                      'No email',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed(Routes.editProfile.path);
                                    },
                                    child: const Text("Edit profile"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            'assets/reward_ribbon.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Reward points",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "10",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              }),
        ),
        Align(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _authService.logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login.path,
                      (_) => false,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.logout),
                  ),
                  const Text("Logout"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
