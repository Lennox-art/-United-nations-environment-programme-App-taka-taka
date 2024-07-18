import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/cloud_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});



  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final _nameController = TextEditingController(text: _auth.userNotifier.value?.displayName);
  final AuthService _auth = getIt<AuthService>();
  final FirebaseCloudStorage _storage = getIt<FirebaseCloudStorage>();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    return ValueListenableBuilder(
        valueListenable: _auth.userNotifier,
        builder: (_, user,__) {
          if (user == null) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("User not found"),
            );
          }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile Page'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user.photoURL ?? ""),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 30),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PickImageSourceDialog(
                              onPickImage: (file) {
                                _storage.uploadFile(
                                  ref: "/images/profile/${user.uid}/profile_image.${file.name.split(".").last}",

                                  uploadData: (ref) async {
                                    var data = await file.readAsBytes();
                                    await ref.putData(data);
                                  },
                                  onSuccess: (photoUrl) {
                                    print("Photo success == $photoUrl");
                                    _auth.changeProfilePicture(photoUrl);
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  onFailure: (error) {
                                    print("Photo failed == $error");
                                    Navigator.of(context).pop();
                                  }
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      onChanged: (s) {
                        setState(() {

                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        suffix: Visibility(
                          visible: user?.displayName != _nameController.text,
                          child: IconButton(onPressed: () {
                            setState(() {
                              _auth.changeDisplayName(_nameController.text);
                            });
                          }, icon: Icon(Icons.check)),
                        )
                      ),
                    ),
                    SizedBox(height: 10),

                    ListTile(
                      leading: Icon(Icons.mail),
                      title: Text(user?.email ?? 'no email'),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class PickImageSourceDialog extends StatelessWidget {
  PickImageSourceDialog({
    required this.onPickImage,
    super.key,
  });

  final ImagePicker picker = ImagePicker();
  final Function(XFile) onPickImage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Card(
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          var file = await picker.pickImage(

                              source: ImageSource.camera);
                          if (file == null) return;

                          onPickImage(file);
                        },
                        iconSize: 50,
                        icon: Icon(Icons.camera_alt_outlined)),
                    Text("Camera"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          var file = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (file == null) return;

                          onPickImage(file);
                        },
                        iconSize: 50,
                        icon: Icon(Icons.image_outlined)),
                    Text("Gallery"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

