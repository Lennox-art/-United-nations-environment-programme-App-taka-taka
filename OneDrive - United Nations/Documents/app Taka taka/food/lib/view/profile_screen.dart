import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/routes/routes.dart';
import 'package:food/view_model/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();
  late final User? user = _authService.user;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Profile"),

        const Divider(
          thickness: 1,
          color: Colors.black,
        ),

        Visibility(
          visible: user != null,
          replacement: const Text("User data not found"),
          child: Expanded(
            child: Container(
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 80,
                    child: Icon(Icons.person_outline),
                  ),

                  Builder(
                    builder: (context) {
                      var emailNames = user!.email!.split("@");
                      var allNames = emailNames.first.split(".");

                      return ListTile(
                        title: Text("${allNames.firstOrNull} ${allNames.lastOrNull}"),
                      );
                    }
                  ),

                  ListTile(
                    title: Text(user!.email!),
                  )
                ],
              ),
            ),
          ),
        ),

         Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/reward_ribbon.png',
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Text("Reward points"),
              ],
            ),

            Text("125"),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {

            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                TextStyle(),
              ),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0))
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings),
                const Text("Settings"),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.login.path,
                (_) => false,
              );
            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                TextStyle(),
              ),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                ),
              ),
            ),
            child: const Text("Logout"),
          ),
        ),
      ],
    );
  }
}
