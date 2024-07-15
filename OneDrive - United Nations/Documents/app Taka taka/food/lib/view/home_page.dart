import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food/firebase_options.dart';
import 'package:food/routes/routes.dart';
import 'package:food/theme/themes.dart';
import 'package:food/view/edit_profile_page.dart';
import 'package:food/view/login_screen.dart';
import 'package:food/view/new_post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'view/login_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';


class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: HomeTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Post(
                username: 'Kareem Aljabari',
                timeAgo: '1h ago',
                content: 'The always cheerful spirit of sunflowers inspires me to always be optimistic in facing...',
                imageUrl: 'https://images.pexels.com/photos/1169084/pexels-photo-1169084.jpeg?cs=srgb&dl=pexels-suju-1169084.jpg&fm=jpg', // Replace with actual image URL
                likes: '128K',
                comments: 'Cutsyifa and 128K others',
              ),
              Post(
                username: 'Sara Almasi',
                timeAgo: '8m ago',
                content: "Success does not happen overnight. Keep your eye on the prize and don't look back...",
                imageUrl: 'https://img.freepik.com/free-photo/natures-beauty-captured-colorful-flower-close-up-generative-ai_188544-8593.jpg', // Replace with actual image URL
                likes: '75K',
                comments: 'Cutsyifa and 75K others',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Post extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String content;
  final String imageUrl;
  final String likes;
  final String comments;

  const Post({
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://example.com/profile.jpg'), // Replace with actual profile image URL
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(timeAgo),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(content),
            SizedBox(height: 8.0),
            Image.network(imageUrl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {
                        // Handle like button press
                      },
                    ),
                    Text(likes),
                  ],
                ),
                Text(comments),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
