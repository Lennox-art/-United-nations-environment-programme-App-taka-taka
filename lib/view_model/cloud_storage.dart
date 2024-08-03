
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudStorage {

  final FirebaseStorage _storage = FirebaseStorage.instance;



  Future<void> uploadFile({
    required String ref,
    required Function(Reference) uploadData,
    required Function(String) onSuccess,
    Function(String)? onFailure,
}) async {
    var storageRef = _storage.ref(ref);
   var uploadTask =  await uploadData(storageRef);


   switch(uploadTask.state) {
     case TaskState.paused:
       //When upload paused
       break;
     case TaskState.running:
       //Maybe progress
       break;
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