import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                              const Text('Welcome!',
                                  style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Text(user?.displayName ?? '',
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
            future: Future.wait<dynamic>(
                [_firestore.fetchAdminPosts(), _firestore.getPosts(),  ]),
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const LoadingIndicator();
              }

              List<dynamic> data = snap.data ?? [];
              if (data.isEmpty) {
                return const Text("No posts available");
              }

              List<dynamic> combinedList = data.expand((list) => list).toList();

              return ListView.builder(
                itemCount: combinedList.length,
                itemBuilder: (_, i) {
                  dynamic p = combinedList[i];
                  print("index: $i");
                  print("data: ${p.toString()}");
                  print("${p.runtimeType} = Runtime Type");
                  print("${p is UserPostsModel} = PostsModel");
                  print("${p is AdminPost} = AdminPost");

                  if (p is UserPostsModel) {
                    return UserPostWidget(
                      p: p,
                      firestore: _firestore,
                      authService: _authService,
                    );
                  }

                  if (p is AdminPost) {
                    return AdminPostWidget(p: p);
                  }

                  return Text("Unknown type");
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserPostWidget extends StatelessWidget {
  const UserPostWidget({
    required this.p,
    required this.firestore,
    required this.authService,
    super.key,
  });

  final AuthService authService;
  final FirestoreService firestore;
  final UserPostsModel p;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserData(p.postedByUserId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }

          User? user = snap.data;

          return Post(
            user: user,
            postsModel: p,
            onVote: () {
              String? userId = authService.userNotifier.value?.uid;
              if (userId == null) return;
              print("User id present");
              if (p.votes.contains(userId)) return;

              print("New vote");

              p.votes.add(userId);

              firestore.savePost(p);

              print("Updated post");
            },
          );
        });
  }
}

class AdminPostWidget extends StatelessWidget {
  const AdminPostWidget({
    required this.p,
    super.key,
  });

  final AdminPost p;

  @override
  Widget build(BuildContext context) {
    return switch (p.postType) {
      AdminPostType.estimation => EstimationAdminPostWidget(p: p),
      AdminPostType.congratulatory => CongratulatoryAdminPostWidget(p: p),
    };
  }
}

class EstimationAdminPostWidget extends StatelessWidget {
  EstimationAdminPostWidget({required this.p, super.key});

  final AdminPost p;
  final TextEditingController estimationController = TextEditingController();
  final ValueNotifier<bool> showTextField = ValueNotifier(false);
  final ValueNotifier<Metric> metricNotifier = ValueNotifier(Metric.kgs);
  final FirestoreService firestore = getIt<FirestoreService>();
  late final currentUserId = firestore.currentUser.value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder(
          future: getUserData(p.postedBy),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LoadingIndicator();
            }

            User? user = snap.data;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
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
                          Text(timeago.format(p.postedAt)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(p.content),
                  ValueListenableBuilder(
                    valueListenable: metricNotifier,
                    builder: (_, metric, __) {
                      if (currentUserId == null) {
                        return const Text("No user data found");
                      }

                      if (currentUserId!.role == UserRoles.admin) {
                        return ListTile(
                          title: const Text("Total submissions"),
                          subtitle: Text("${p.userPollData.length} submissions"),
                        );
                      }

                      PollData? userPollData = p.userPollData[currentUserId?.id];

                      return Visibility(
                        visible: userPollData != null,
                        replacement: ValueListenableBuilder(
                          valueListenable: showTextField,
                          builder: (_, show, __) {
                            return Visibility(
                              visible: show,
                              replacement: Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showTextField.value = true;
                                  },
                                  child: const Text("Click to submit"),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: estimationController,
                                        keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                        validator: (s) => (s?.isEmpty ?? false)
                                            ? "Amount required"
                                            : null,
                                        decoration: InputDecoration(
                                          
                                          labelText: "Estimation",
                                          hintText: "20 ${metric.name}",
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButton<Metric>(
                                            value: metric,
                                            isDense: true,
                                            isExpanded: true,
                                            hint: const Text('Select a metric'),
                                            items: Metric.values.map((r) {
                                              return DropdownMenuItem<Metric>(
                                                value: r,
                                                child: Text(r.name.toUpperCase()),
                                              );
                                            }).toList(),
                                            onChanged: (c) {
                                              if (c == null) return;
                                              metricNotifier.value = c;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        double? estimate = double.tryParse(
                                          estimationController.text,
                                        );
                                        if (estimate == null) return;

                                        print("Posting estimate ${estimate}");

                                        p.userPollData.putIfAbsent(
                                          currentUserId!.id,
                                              () => PollData(
                                            userId: currentUserId!.id,
                                            value: estimate,
                                            timestamp: DateTime.now(),
                                            metric: metric,
                                          ),
                                        );

                                        print("Saving ${p.toString()}");

                                        firestore.saveAdminPost(p);
                                      },
                                      child: Text("Submit"),
                                    ),
                                    TextButton(onPressed: () {
                                      showTextField.value = false;
                                      estimationController.clear();
                                    }, child: Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 13,),textAlign: TextAlign.left,),),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          title: const Text("You have submitted your estimate"),
                          subtitle: Text("${userPollData?.value} ${userPollData?.metric.name}"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

class CongratulatoryAdminPostWidget extends StatelessWidget {
  const CongratulatoryAdminPostWidget({required this.p, super.key});

  final AdminPost p;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder(
          future: getUserData(p.postedBy),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LoadingIndicator();
            }

            User? user = snap.data;
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
                            Text(timeago.format(p.postedAt)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(p.content),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            );
        }
      ),
    );
  }
}

class Post extends StatelessWidget {
  final User? user;
  final UserPostsModel postsModel;
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
