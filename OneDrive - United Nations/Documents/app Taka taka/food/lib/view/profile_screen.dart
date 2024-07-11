import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/routes/routes.dart';
import 'package:food/view_model/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Profile"),
        ElevatedButton(
          onPressed: () async {
            await _authService.logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.login.path,
              (_) => false,
            );
          },
          child: Text("Logout"),
        ),
      ],
    );
  }
}
