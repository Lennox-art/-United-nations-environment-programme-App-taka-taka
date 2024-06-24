import 'package:flutter/material.dart';

class ContentManagementScreen extends StatelessWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Implement add content logic
              },
              child: const Text('Add Content'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement update content logic
              },
              child: const Text('Update Content'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement delete content logic
              },
              child: const Text('Delete Content'),
            ),
          ],
        ),
      ),
    );
  }
}
