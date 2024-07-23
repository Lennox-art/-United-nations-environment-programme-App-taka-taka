import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:food/view_model/functions.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = getIt<AuthService>();
  final FirestoreService _firestore = getIt<FirestoreService>();


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
                    valueListenable: _firestore.currentUser,
                    builder: (_, user, __) {
                      return Row(
                        children: [
                          Visibility(
                            visible: user?.photoUrl != null,
                            replacement: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            child: CircularPhoto(
                              radius: 50,
                              url: user?.photoUrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Welcome back!',
                                  style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Text(
                                      user?.displayName ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.waving_hand,
                                      color: Colors.orange),
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
                /*Visibility(
                  visible: _searchController.text.isNotEmpty,
                  replacement: IconButton(
                    onPressed: () {
                      _searchController.text = " ";
                    },
                    icon: const Icon(Icons.search),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _searchController.text = "";
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),*/
              ],
            );
          }),
        ),
        Expanded(
          child: FutureBuilder(
            future: _firestore.getPosts(),
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const LoadingIndicator();
              }

              List<PostsModel> data = snap.data ?? [];
              if (data.isEmpty) {
                return const Text("No posts available");
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, i) {
                  PostsModel p = data[i];



                  return FutureBuilder(
                    future: getUserData(p.postedByUserId),
                    builder: (context, snap) {

                      if(snap.connectionState != ConnectionState.done) {
                        return const LoadingIndicator();
                      }

                      User? user = snap.data;

                      return Post(
                        user: user,
                        postsModel: p,
                        onVote: () {
                          String? userId = _authService.userNotifier.value?.uid;
                          if (userId == null) return;
                          print("User id present");
                          if (p.votes.contains(userId)) return;

                          print("New vote");

                          p.votes.add(userId);

                          _firestore.savePost(p);

                          print("Updated post");
                        },
                      );
                    }
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
  final User? user;
  final PostsModel postsModel;
  final Function()? onVote;

  const Post({
    super.key,
    required this.user,
    required this.postsModel,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    Duration time = DateTime.now().difference(postsModel.createdAt);
    DateTime timeAt = DateTime.now().subtract(time);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircularPhoto(
                  url: user?.photoUrl,
                  radius: 40,
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(timeago.format(timeAt)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(postsModel.content),
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.center,
              child: RectangularPhoto(
                url: postsModel.imageUrl,
              ),
            ),
            Visibility(
              visible: onVote != null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: onVote,
                      ),
                      Text("${postsModel.votes.length} votes"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
