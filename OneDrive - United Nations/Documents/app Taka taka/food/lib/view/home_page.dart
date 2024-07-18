import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = getIt<AuthService>();
  final FirestoreService _firestore = getIt<FirestoreService>();

  List<Post> get dummyPosts => [
        Post(
          username: 'Kareem Aljabari',
          timeAgo: '1h ago',
          content:
              'The always cheerful spirit of sunflowers inspires me to always be optimistic in facing...',
          imageUrl:
              'https://images.pexels.com/photos/1169084/pexels-photo-1169084.jpeg?cs=srgb&dl=pexels-suju-1169084.jpg&fm=jpg',
          // Replace with actual image URL
          votes: '128K',
          onVote: () {},
        ),
        Post(
          username: 'Sara Almasi',
          timeAgo: '8m ago',
          content:
              "Success does not happen overnight. Keep your eye on the prize and don't look back...",
          imageUrl:
              'https://images.pexels.com/photos/1169084/pexels-photo-1169084.jpeg?cs=srgb&dl=pexels-suju-1169084.jpg&fm=jpg',
          // Replace with actual image URL
          votes: '75K',
          onVote: () {},
        ),
      ];

  @override
  void initState() {
    super.initState();

    _firestore.getPosts().then((posts) {
      print("${posts.length} posts found");
    }).catchError((e, trace) {
      print("${e.toString()} $trace posts fetch error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _searchController.text.isNotEmpty,
                  replacement: ValueListenableBuilder(
                    valueListenable: _authService.userNotifier,
                    builder: (_, user, __) {
                      return  Row(
                        children: [

                          Visibility(
                            visible: user?.photoURL != null,
                            replacement: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            child:  CircleAvatar(
                              backgroundColor: Colors.blue,
                              backgroundImage: NetworkImage(user!.photoURL!),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back!', style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Text(
                                      _authService
                                          .userNotifier.value?.displayName ??
                                          '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  SizedBox(width: 5),
                                  Icon(Icons.waving_hand, color: Colors.orange),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: FutureBuilder(
            future: _firestore.getPosts(),
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }

              List<PostsModel> data = snap.data ?? [];
              if (data.isEmpty) {
                return Text("No posts available");
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, i) {
                  PostsModel p = data[i];

                  Duration timeAgo = DateTime.now().difference(p.createdAt);

                  return Post(
                    username: p.postedByDisplayName,
                    timeAgo: "${timeAgo.inMinutes}'s ago",
                    content: p.content,
                    imageUrl: p.imageUrl,
                    // Replace with actual image URL
                    votes: "${p.votes.length} votes",
                    onVote: () {
                      String? userId = _authService.userNotifier.value?.uid;
                      if(userId == null) return;
                      print("User id present");
                      if(p.votes.contains(userId)) return;

                      print("New vote");


                      p.votes.add(userId);

                      _firestore.savePost(p);

                      print("Updated post");

                    },
                  );
                },
              );
            },
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
  final String votes;
  final Function() onVote;

  const Post({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.votes,
    required this.onVote,
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
                  backgroundImage: NetworkImage(
                      imageUrl), // Replace with actual profile image URL
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
            Align(
              alignment: Alignment.center,
              child: Image.network(
                imageUrl,
                loadingBuilder: (_, __, ___) => CircularProgressIndicator(),
                errorBuilder: (_, e, ___) => Icon(Icons.image),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      onPressed: onVote,
                    ),
                    Text(votes),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
