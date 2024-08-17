import 'package:flutter/material.dart';

void main() {
  runApp(TakaTakaApp());
}

class TakaTakaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessageImageSharingScreen(),
    );
  }
}

class MessageImageSharingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taka taka app'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Message 1:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '"🌍 Small actions make a big difference! Reduce, reuse, and recycle to help keep our planet green and clean. #EcoFriendly #Sustainability"',
              style: TextStyle(fontSize: 16),
            ),
            TextButton.icon(
              icon: Icon(Icons.share, color: Colors.blue),
              label: Text('Share'),
              onPressed: () {
                // Add your share logic here
              },
            ),
            SizedBox(height: 20),

            Text(
              'Message 2:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '"🌱 Did you know? Planting trees can significantly reduce carbon footprints. Join us in our tree-planting campaign and make a positive impact on the environment! #PlantATree #ClimateAction"',
              style: TextStyle(fontSize: 16),
            ),
            TextButton.icon(
              icon: Icon(Icons.share, color: Colors.blue),
              label: Text('Share'),
              onPressed: () {
                // Add your share logic here
              },
            ),
            SizedBox(height: 20),

            Text(
              'Message 3:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '"💧 Save water, save life! Simple changes like fixing leaks and turning off the tap while brushing your teeth can conserve precious water resources. #WaterConservation #EcoTips"',
              style: TextStyle(fontSize: 16),
            ),
            TextButton.icon(
              icon: Icon(Icons.share, color: Colors.blue),
              label: Text('Share'),
              onPressed: () {
                // Add your share logic here
              },
            ),
            SizedBox(height: 20),

            // Images Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/image1.png', width: 100, height: 100),
                Image.asset('assets/image2.png', width: 100, height: 100),
              ],
            ),
            TextButton.icon(
              icon: Icon(Icons.share, color: Colors.blue),
              label: Text('Share'),
              onPressed: () {
                // Add your share logic here
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate to home
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Navigate to notifications
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Navigate to profile
              },
            ),
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Navigate to admin panel
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFloatingActionMenu(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showFloatingActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('New Post'),
              onTap: () {
                // Navigate to new post screen
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Message and Image Sharing'),
              onTap: () {
                // Navigate to message and image sharing screen
              },
            ),
          ],
        );
      },
    );
  }
}
