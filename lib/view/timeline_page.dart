import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/theme/themes.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:food/view_model/functions.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key});

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Visibility(
          visible: _searchController.text.isNotEmpty,
          replacement: ValueListenableBuilder(
            valueListenable: _firestore.currentUser,
            builder: (_, user, __) {
              return FutureBuilder(
                future: Future.wait<dynamic>([
                  _firestore.fetchAdminPosts(),
                  _firestore.getPosts(),
                ]),
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const LoadingIndicator();
                  }

                  List<dynamic> data = snap.data ?? [];
                  if (data.isEmpty) {
                    return const Text("No posts available");
                  }

                  List<dynamic> combinedList =
                  data.expand((list) => list).toList();

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

                      return const Text("Unknown type");
                    },
                  );
                },
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
      ),
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
                            Row(
                              children: [
                                Text(
                                  user?.displayName ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.flag,
                                  color: Colors.blue,
                                ),
                              ],
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
                            subtitle:
                            Text("${p.userPollData.length} submissions"),
                          );
                        }

                        PollData? userPollData =
                        p.userPollData[currentUserId?.id];

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
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: TextFormField(
                                          controller: estimationController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                            decimal: true,
                                            signed: true,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (s) =>
                                          (s?.isEmpty ?? false)
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
                                              hint:
                                              const Text('Select a metric'),
                                              items: Metric.values.map((r) {
                                                return DropdownMenuItem<Metric>(
                                                  value: r,
                                                  child: Text(
                                                      r.name.toUpperCase()),
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
                                      TextButton(
                                        onPressed: () {
                                          showTextField.value = false;
                                          estimationController.clear();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
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
                            title:
                            const Text("You have submitted your estimate"),
                            subtitle: Text(
                                "${userPollData?.value} ${userPollData?.metric.name}"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
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
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                            Row(
                              children: [
                                Text(
                                  user?.displayName ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.flag,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            Text(timeago.format(p.postedAt)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(p.content),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        showBottomSheet(
                          enableDrag: true,
                          showDragHandle: true,
                          elevation: 12.0,
                          context: context,
                          builder: (_) => CommentBottomSheet(
                            p: p,
                            onClosing: () {},
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat),
                          Text(" ${p.comments.length} Comments")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
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

class CommentBottomSheet extends StatelessWidget {
  final AdminPost p;

  final void Function() onClosing;

  late final ValueNotifier<List<UserComment>> comments =
  ValueNotifier(p.comments);

  final TextEditingController commentController = TextEditingController();

  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  final ValueNotifier<bool> showPostNotifier = ValueNotifier(false);

  CommentBottomSheet({
    required this.onClosing,
    required this.p,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    comments.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return BottomSheet(
      backgroundColor: Colors.transparent,
      onClosing: onClosing,
      builder: (context) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 700,
            maxWidth: 1000,
            minHeight: 350,
            minWidth: 300,
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Comments",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: comments,
                    builder: (_, commentsList, __) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: commentsList.length,
                        itemBuilder: (_, i) {
                          var c = commentsList[i];
                          return CommentTile(
                            comment: c,
                          );
                        },
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: commentController,
                  onChanged: (s) => showPostNotifier.value = s.isNotEmpty,
                  decoration: InputDecoration(
                    hintText: "Congratulations",
                    labelText: "Comment",
                    suffix: ValueListenableBuilder(
                      valueListenable: showPostNotifier,
                      builder: (_, showPost, __) {
                        return Visibility(
                          visible: showPost,
                          child: ValueListenableBuilder(
                            valueListenable: loadingNotifier,
                            builder: (_, loading, __) {
                              return Visibility(
                                visible: !loading,
                                replacement: const LoadingIndicator(),
                                child: IconButton(
                                  onPressed: () async {
                                    String comment = commentController.text;
                                    if (comment.isEmpty) return;

                                    FirestoreService firestore =
                                    getIt<FirestoreService>();

                                    String? userId =
                                        firestore.currentUser.value?.id;
                                    if (userId == null) return;

                                    loadingNotifier.value = true;

                                    try {
                                      p.comments.add(
                                        UserComment(
                                          userId: userId,
                                          comment: comment,
                                          timestamp: DateTime.now(),
                                        ),
                                      );

                                      await firestore.saveAdminPost(p);
                                      commentController.clear();
                                      comments.value = List.from(p.comments);
                                    } catch (e) {
                                      print(e.toString());
                                    } finally {
                                      loadingNotifier.value = false;
                                    }
                                  },
                                  icon: const Icon(Icons.send),
                                  color: highlightBlue,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    super.key,
  });

  final UserComment comment;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserData(comment.userId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }

          User? user = snap.data;

          return ListTile(
            leading: SizedBox(
              width: 70,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularPhoto(
                    url: user?.photoUrl,
                    radius: 40,
                  ),
                  Text(
                    user?.displayName ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            title: Text(comment.comment),
            subtitle: Text(timeago.format(comment.timestamp)),
          );
        });
  }
}