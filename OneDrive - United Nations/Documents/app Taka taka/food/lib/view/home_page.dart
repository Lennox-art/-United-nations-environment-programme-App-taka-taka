import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  Future<String?> _getUserName() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserName(),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Test Acc';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _searchController.text.isNotEmpty,
                    replacement: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back!', style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(width: 5),
                                Icon(Icons.waving_hand, color: Colors.orange),
                              ],
                            ),
                          ],
                        ),


                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SearchBar(
                        controller: _searchController,
                      ),
                    ),
                  ),
                  Visibility(
                      visible: _searchController.text.isNotEmpty,
                      replacement: IconButton(
                          onPressed: () {
                            _searchController.text = " ";
                          },
                          icon: Icon(Icons.search),
                      ),
                      child: IconButton(
                          onPressed: () {
                            _searchController.text = "";

                          },
                          icon: Icon(Icons.close),
                      ),
                  )
                ],
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
                    imageUrl: 'https://images.pexels.com/photos/1169084/pexels-photo-1169084.jpeg?cs=srgb&dl=pexels-suju-1169084.jpg&fm=jpg', // Replace with actual image URL
                    likes: '75K',
                    comments: 'Cutsyifa and 75K others',
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

  const Post({super.key,
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
                  backgroundImage: NetworkImage(imageUrl), // Replace with actual profile image URL
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
