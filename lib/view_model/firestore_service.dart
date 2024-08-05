import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:food/model/models.dart';
import 'package:food/view/home_page.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<User?> currentUser = ValueNotifier(null);

  String userProfilePath({
    required String userId,
    required String role,
  }) =>
      "user/";

  Future<void> savePost(UserPostsModel post) async {
    await _firestore.collection("posts").doc(post.id).set(post.toJson());
  }

  Future<List<UserPostsModel>> getPosts() async {
    var data = await _firestore
        .collection("posts")
        .orderBy('created_at', descending: true)
        .get();
    return data.docs.map((d) => UserPostsModel.fromJson(d.data())).toList();
  }

  Future<List<UserPostsModel>> getMostVotedPosts({int limit = 3}) async {
    var data = await _firestore
        .collection('posts')
        .orderBy('votes', descending: true)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return data.docs.map((d) => UserPostsModel.fromJson(d.data())).toList();
  }

  Future<List<User>> getAllUsers() async {
    var data = await _firestore
        .collection('users')
        .orderBy('created_at', descending: true)
        .get();

    return data.docs.map((d) => User.fromJson(d.data())).toList();
  }

  Future<void> saveUser(User user) async {
    return _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<User?> getUserById(String userId) async {
    var document = await _firestore.collection('users').doc(userId).get();

    if (!document.exists) return null;

    return User.fromJson(document.data()!);
  }

  Future<void> saveAdminPost(AdminPost adminPost) async {
    return _firestore
        .collection('admin_posts')
        .doc(adminPost.id)
        .set(adminPost.toJson());
  }

  Future<List<AdminPost>> fetchAdminPosts() async {
    var data = await _firestore
        .collection('admin_posts')
        .orderBy('posted_at', descending: true)
        .get();

    return data.docs.map((d) => AdminPost.fromJson(d.data())).toList();
  }

  Future<List<AdminPost>> wasteEstimationPosts() async {
    var data = await _firestore
        .collection('admin_posts')
        .where('post_type', isEqualTo: AdminPostType.estimation.name)
        .orderBy('posted_at', descending: true)
        .get();

    return data.docs.map((d) => AdminPost.fromJson(d.data())).toList();
  }
}
