import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/cloud_storage.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final FirebaseCloudStorage _storage = getIt<FirebaseCloudStorage>();
  final FirestoreService _firestore = getIt<FirestoreService>();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _captureImage() async {
    final capturedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = capturedFile;
    });
  }

  void _submitPost() {
    if (_imageFile == null || _descriptionController.text.isEmpty) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and enter a description.'),
        ),
      );
      return;
    }

    String? postedByDisplayName =
        getIt<AuthService>().userNotifier.value?.displayName;
    if (postedByDisplayName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please logout'),
        ),
      );
    }

    String postId = const Uuid().v4();

    //post to bucket
    _storage.uploadFile(
        ref: "/posts/$postId",
        uploadData: (storageRef) async {
          var data = await _imageFile!.readAsBytes();
          return await storageRef.putData(data);
        },
        onSuccess: (photoUrl) async {
          print("Photo success == $photoUrl");

          //post to firestore
          String content = _descriptionController.text;
          PostsModel posts = PostsModel(
            id: postId,
            postedByDisplayName: postedByDisplayName!,
            createdAt: DateTime.now(),
            content: content,
            imageUrl: photoUrl,
          );

          await _firestore.savePost(posts);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Posted successfully'),
              ),
            );
          }
        },
        onFailure: (error) {
          print("Photo failed == $error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong'),
            ),
          );
        });

    // Handle post submission logic here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if(_imageFile == null) {
                    return const Text('No image selected.');
                  }
                  return FutureBuilder(
                      future: _imageFile!.readAsBytes(),
                      builder: (_, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const CircularProgressIndicator();
                        }

                        if (snap.hasData) {
                          return Image.memory(snap.requireData);
                        }

                        if (snap.hasError) {
                          return Text(snap.error.toString());
                        }

                        return Text("Pick an image");
                      });
                }
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
