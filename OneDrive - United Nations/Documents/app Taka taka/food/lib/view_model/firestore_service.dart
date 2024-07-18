

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/model/models.dart';
import 'package:food/view/home_page.dart';



class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userProfilePath({
    required String userId,
    required String role,
  }) => "user/";


  Future<void> savePost(PostsModel post) async {
    await _firestore.collection("posts").doc(post.id).set(post.toJson());
  }

  Future<List<PostsModel>> getPosts() async {
   var data = await _firestore.collection("posts").get();
   return data.docs.map((d) => PostsModel.fromJson(d.data())).toList();
  }



}