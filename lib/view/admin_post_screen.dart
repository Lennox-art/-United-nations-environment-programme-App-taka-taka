import 'package:flutter/material.dart';
import 'package:food/main.dart';
import 'package:food/model/models.dart';
import 'package:food/view/widgets/reusable_widgets.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:uuid/uuid.dart';

class AdminPostScreen extends StatefulWidget {
  @override
  _AdminPostScreenState createState() => _AdminPostScreenState();
}

class _AdminPostScreenState extends State<AdminPostScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  AdminPostType? selectedPostType;

  Future<void> _postContent() async {
    try {
      // Implement your post content logic here
      debugPrint("Posted: ${_controller.text}");

      if (selectedPostType == null) return;

      String content = _controller.text;
      if (content.length < 3) return;

      loadingNotifier.value = true;

      AdminPost newAdminPost = AdminPost(
        id: const Uuid().v4().toString(),
        content: content,
        postType: selectedPostType!,
        userPollData: {},
        comments: [],
        postedBy: _firestoreService.currentUser.value!.id,
        postedAt: DateTime.now(),
      );

      await _firestoreService.saveAdminPost(newAdminPost);
      _cancel();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingNotifier.value = false;
    }
  }

  void _cancel() {
    // Clear the input field and navigate back
    _controller.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Post Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taka taka app admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<AdminPostType>(
              hint: Text("Choose type of post"),
              value: selectedPostType,
              items: AdminPostType.values.map((value) {
                return DropdownMenuItem<AdminPostType>(
                  value: value,
                  child: Text(value.value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedPostType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your post here',
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValueListenableBuilder(
                    valueListenable: loadingNotifier,
                    builder: (_, loading, __) {
                      return Visibility(
                        visible: !loading,
                        replacement: const LoadingIndicator(),
                        child: ElevatedButton(
                          onPressed: _postContent,
                          child: Text('Post'),
                        ),
                      );
                    }),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancel,
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
