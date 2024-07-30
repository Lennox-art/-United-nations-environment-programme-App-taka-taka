import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view/home_page.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/firestore_service.dart'; // Assuming you have models defined for Post and Estimate

class AdminTab extends StatelessWidget {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // _buildCorrectEstimateSection(),
            // _buildUserEstimatesSection(),
            _buildMostVotedPostsSection(),
            AllUsersTab(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildMostVotedPostsSection() {
    return FutureBuilder<List<PostsModel>>(
      future: _firestoreService.getMostVotedPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        var posts = snapshot.requireData;
        posts.sort((a, b) => b.votes.length.compareTo(a.votes.length));

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Most Voted Posts'),
              ),
            ],
          ),
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
    );
  }
}
