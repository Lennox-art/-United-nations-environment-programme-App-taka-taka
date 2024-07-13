

import 'package:cloud_firestore/cloud_firestore.dart';



class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userProfilePath({
    required String userId,
    required String role,
  }) => "user/";


  Future<void> saveData() async {

    // _firestore.collection(collectionPath)

  }

}