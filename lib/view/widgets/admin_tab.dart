import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:food/view_model/functions.dart'; // Assuming you have models defined for Post and Estimate
import 'package:timeago/timeago.dart' as timeago;
class MVPPage extends StatelessWidget {
  MVPPage({super.key});

  final FirestoreService _firestoreService = getIt<FirestoreService>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Most voted posts"),
      ),
      body: FutureBuilder<List<UserPostsModel>>(
        future: _firestoreService.getMostVotedPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          var posts = snapshot.requireData;
          posts.sort((a, b) => b.votes.length.compareTo(a.votes.length));

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Most Voted Posts'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final FirestoreService _service = getIt<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
      ),
      body: FutureBuilder(
        initialData: const <User>[],
        future: _service.getAllUsers(),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }

          if (snap.hasError) {
            return ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text("Retry"),
            );
          }

          var users = snap.requireData;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (_, i) {
              User u = users[i];
              return ListTile(
                leading: CircularPhoto(
                  url: u.photoUrl,
                  radius: 25,
                ),
                title: Text(u.displayName),
                subtitle: Text(u.id),
                trailing: Text(u.role.name),
              );
            },
          );
        },
      ),
    );
  }
}

class WasteEstimation extends StatefulWidget {
  const WasteEstimation({super.key});

  @override
  State<WasteEstimation> createState() => _WasteEstimationState();
}

class _WasteEstimationState extends State<WasteEstimation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste estimation"),
      ),
      body: FutureBuilder<List<AdminPost>>(
        future: getIt<FirestoreService>().wasteEstimationPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }

          if (!snapshot.hasData) {
            return Column(
              children: [
                const Text("No posts"),
                ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Icon(Icons.replay)),
              ],
            );
          }

          List<AdminPost> posts = snapshot.requireData;
      //        posts.sort((a, b) => b.votes.length.compareTo(a.votes.length));

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) {
              AdminPost p = posts[i];
              List<PollData> pollData = p.userPollData.values.toList();

              return FutureBuilder(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text("Submissions", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text("List of estimates", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: pollData.length,
                                  itemBuilder: (_, i) {
                                    PollData poll = pollData[i];
                                    return Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("${i + 1}. "),
                                        FutureBuilder(
                                            future: getUserData(poll.userId),
                                            builder: (context, snap) {
                                              if (snap.connectionState != ConnectionState.done) {
                                                return const LoadingIndicator();
                                              }

                                              User? user = snap.data;
                                              return Row(
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
                                              );
                                            }
                                        ),
                                        Text("${poll.value} ${poll.metric.name}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),textAlign: TextAlign.center),
//                                        Text(formatDateTime(poll.timestamp), textAlign: TextAlign.center,),
                                      ],
                                    );
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              );
            },
          );
        },
      ),
    );
  }
}