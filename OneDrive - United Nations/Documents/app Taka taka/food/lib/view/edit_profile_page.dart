import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/view_model/auth_service.dart';
import 'package:food/view_model/cloud_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({this.name, super.key});

  final String? name;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final _nameController = TextEditingController(text: widget.name);
  late final _emailController = TextEditingController(text: user?.email);
  final AuthService _auth = AuthService();
  final FirebaseCloudStorage _storage = FirebaseCloudStorage();
  late final User? user = _auth.user;

  @override
  Widget build(BuildContext context) {


    if (user == null) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("User not found"),
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
                  child: Visibility(
                    visible: user?.photoURL != null && user!.photoURL!.isNotEmpty,
                    replacement: const Icon(Icons.person_outline),
                    child: Image.network(user?.photoURL ?? ""),
                  ),
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
                              ref: "/images/profile/${user!.uid}/profile_image.${file.name.split(".").last}",
                              file: File(file.path),
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
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (b) {
                        return ChangePasswordDialog();
                      },
                    );
                  },
                  child: Text("Change password"),
                ),
                SizedBox(height: 20),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Handle save changes
              },
              child: Text('Save changes'),
            ),
          ],
        ),
      ),
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

class ChangePasswordDialog extends StatelessWidget {
  ChangePasswordDialog({super.key});

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: TextField(
                  controller: _oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle save changes
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
