import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food/routes/routes.dart';
import 'package:food/theme/themes.dart';
import 'package:food/view/edit_profile_page.dart';
import 'package:food/view/new_post_screen.dart';
import 'package:food/view/splash_screen.dart';
import 'package:food/view/super_page.dart';

import 'firebase_options.dart';
import 'view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taka taka app',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: {
        Routes.splashScreen.path: (_) => SplashScreenPage(),
        Routes.login.path: (_) => LoginScreen(),
        Routes.superPage.path: (_) => SuperPageScreen(),
        Routes.newPost.path: (_) => NewPostScreen(),
        Routes.editProfile.path: (_) => EditProfilePage(),
      },
    );
  }

}


