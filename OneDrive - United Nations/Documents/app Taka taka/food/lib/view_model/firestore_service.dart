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

  Future<void> savePost(PostsModel post) async {
    await _firestore.collection("posts").doc(post.id).set(post.toJson());
  }

  Future<List<PostsModel>> getPosts() async {
    var data = await _firestore.collection("posts").orderBy('created_at', descending: true).get();
    return data.docs.map((d) => PostsModel.fromJson(d.data())).toList();
  }

  Future<List<PostsModel>> getMostVotedPosts({int limit = 3}) async {
    var data = await _firestore
        .collection('posts')
        .orderBy('votes', descending: true)
        // .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return data.docs.map((d) => PostsModel.fromJson(d.data())).toList();
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
}
