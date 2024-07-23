import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/model/models.dart';
import 'package:food/view/home_page.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/firestore_service.dart'; // Assuming you have models defined for Post and Estimate
import 'package:food/view_model/functions.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AdminSections {
  users("Users", Icons.person),
  mvp("MVP", Icons.celebration);

  final String value;
  final IconData icon;

  const AdminSections(this.value, this.icon);
}

class AdminTab extends StatelessWidget {

  AdminTab({super.key});

  final List<AdminSections> adminSections = AdminSections.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: adminSections.length,
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TabBar(
              tabs: adminSections
                  .map(
                    (e) => Tab(
                      text: e.value,
                      icon: Icon(e.icon),
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: adminSections
                    .map((e) => switch (e) {
                          AdminSections.users => AllUsersTab(),
                          AdminSections.mvp => MVPSection(),
                        },)
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

/*
  * */

/*Widget _buildCorrectEstimateSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestoreService.getCorrectEstimate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Correct Estimate for Last Week: ${data['amount']} kg'),
              ],
            ),
          ),
        );
      },
    );
  }*/

/*Widget _buildUserEstimatesSection() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestoreService.getUserEstimates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var estimates = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Estimate(
            userId: doc.id,
            estimate: data['estimate'],
            deviation: data['deviation'],
          );
        }).toList();

        estimates.sort((a, b) => a.deviation.compareTo(b.deviation));

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('User Estimates'),
              ),
              ...estimates.map((estimate) {
                return ListTile(
                  title: Text('User: ${estimate.userId}'),
                  subtitle: Text('Estimate: ${estimate.estimate} kg, Deviation: ${estimate.deviation} kg'),
                  trailing: estimate.deviation == estimates.first.deviation
                      ? ElevatedButton(
                    onPressed: () {
                      // Reward user
                    },
                    child: Text('Reward'),
                  )
                      : null,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }*/
}

class MVPSection extends StatefulWidget {
  const MVPSection({super.key});

  @override
  State<MVPSection> createState() => _MVPSectionState();
}

class _MVPSectionState extends State<MVPSection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostsModel>>(
      future: getIt<FirestoreService>().getMostVotedPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingIndicator();
        }

        if(!snapshot.hasData) {
          return ElevatedButton(onPressed: () {
            setState(() {

            });
          }, child: Icon(Icons.replay));
        }

        List<PostsModel> posts = snapshot.requireData;
//        posts.sort((a, b) => b.votes.length.compareTo(a.votes.length));

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) {
            PostsModel p = posts[i];
            return FutureBuilder(
                future: getUserData(p.postedByUserId),
                builder: (context, snap) {

                  if(snap.connectionState != ConnectionState.done) {
                    return const LoadingIndicator();
                  }

                  User? user = snap.data;
                return MVPItem(user: user, postsModel: p);
              }
            );
          },
        );
      },
    );
  }
}

class AllUsersTab extends StatefulWidget {
  const AllUsersTab({super.key});

  @override
  State<AllUsersTab> createState() => _AllUsersTabState();
}

class _AllUsersTabState extends State<AllUsersTab> {
  final FirestoreService _service = getIt<FirestoreService>();

  UserRoles get isOnIndicator => UserRoles.admin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          itemCount: users.length,
          itemBuilder: (_, i) {
            User u = users[i];
            return ListTile(
              leading: SizedBox(
                height: 30,
                width: 30,
                child: CircularPhoto(
                  url: u.photoUrl,
                  radius: 25,
                ),
              ),
              title: Text(u.displayName),
              subtitle: Visibility(
                visible: false,
                  child: Text("Joined at ${u.createdAt.toLocal().toString()}")
              ),
              trailing: SizedBox(
                height: 100,
                width: 80,
                child: DropdownButton<UserRoles>(
                  value: u.role,
                  isDense: true,
                  isExpanded: true,
                  hint: Text('Select'),
                  items: allRoles.map((r) {
                    return DropdownMenuItem<UserRoles>(
                      value: r,
                      child: Text(r.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (c) {
                    if (c == null) return;
                    u.role = c;
                    _service.saveUser(u);
                    setState(() {});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MVPItem extends StatelessWidget {
  final User? user;
  final PostsModel postsModel;
  final Function()? onVote;

  const MVPItem({
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_up),
                    Text("${postsModel.votes.length} votes"),
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