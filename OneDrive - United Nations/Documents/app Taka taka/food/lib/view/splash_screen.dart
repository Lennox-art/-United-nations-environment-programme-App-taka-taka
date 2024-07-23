import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/routes/routes.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  final AuthService _authService = getIt<AuthService>();

  @override
  void initState() {

    Future.delayed(const Duration(seconds: 2),
          () {
            // check if user is logged in

            Routes route = _authService.isUserLoggedIn ? Routes.superPage : Routes.login;
            print("Checking if user is logged in : Redirecting to ${route.name}");
            Navigator.of(context).pushNamedAndRemoveUntil(route.path, (_) => false);
            // if not logged in go to login page
          },
    );


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
