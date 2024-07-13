import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudStorage {

  final FirebaseStorage _storage = FirebaseStorage.instance;



  Future<void> uploadFile({
    required String ref,
    required File file,
    required Function(String) onSuccess,
    Function(String)? onFailure,
}) async {
    var storageRef = _storage.ref(ref);
   var uploadTask =  await storageRef.putFile(file);
   switch(uploadTask.state) {
     case TaskState.paused:
       //When upload paused
     case TaskState.running:
       //Maybe progress
     case TaskState.success:
     onSuccess.call(await storageRef.getDownloadURL());
     break;

     case TaskState.canceled:
     onFailure?.call("Upload cancelled");
     break;
     case TaskState.error:
       onFailure?.call("Failed to upload");
       break;
   }
  }

}