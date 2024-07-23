import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
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
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
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

  Future<void> _submitPost() async {


    if (_imageFile == null || _descriptionController.text.isEmpty) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and enter a description.'),
        ),
      );
      return;
    }

    String? postedByUserId = getIt<FirestoreService>().currentUser.value?.id;

    if (postedByUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please logout'),
        ),
      );
    }

    String postId = const Uuid().v4();

    loadingNotifier.value = true;

    //post to bucket
    _storage.uploadFile(
        ref: "/posts/$postId",
        uploadData: (storageRef) async {
          var data = await _imageFile!.readAsBytes();
          return await storageRef.putData(data);
        },
        onSuccess: (photoUrl) async {
          loadingNotifier.value = false;
          print("Photo success == $photoUrl");

          //post to firestore
          String content = _descriptionController.text;
          PostsModel posts = PostsModel(
            id: postId,
            postedByUserId: postedByUserId!,
            createdAt: DateTime.now(),
            content: content,
            imageUrl: photoUrl,
          );

          _firestore.savePost(posts)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Posted successfully'),
              ),
            );

            // Handle post submission logic here
            Navigator.pop(context);
          },).catchError((e, trace) {
            debugPrint("Post failed == $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong'),
              ),
            );
          },)
          ;




        },
        onFailure: (error) {
          loadingNotifier.value = false;
          debugPrint("Photo failed == $error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong'),
            ),
          );
        },
        );




  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: loadingNotifier,
        builder: (_, loading, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Post'),
          ),
          body: Stack(
            children: [

              Visibility(
                visible: loading,
                child: const LoadingIndicator(),
              ),

              Padding(
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
                                  return const LoadingIndicator();
                                }

                                if (snap.hasData) {
                                  return Image.memory(snap.requireData);
                                }

                                if (snap.hasError) {
                                  return Text(snap.error.toString());
                                }

                                return Text("Pick an image");
                              },);
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
                            child: Visibility(
                              visible: !loading,
                              replacement: LoadingIndicator(),
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                label: Text('Gallery'),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Visibility(
                              visible: !loading,
                              replacement: LoadingIndicator(),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.camera_alt),
                                onPressed: _pickImage,
                                label: Text('Camera'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),

                    Visibility(
                      visible: !loading,
                      replacement: LoadingIndicator(),
                      child: ElevatedButton.icon(
                        onPressed: _submitPost,
                        label: Text('Submit Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
