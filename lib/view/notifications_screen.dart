import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notification {
  final String title;
  final String message;
  bool isRead;

  Notification({required this.title, required this.message, this.isRead = false});
}

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notification> notifications = [
    Notification(title: 'Welcome!', message: 'Thank you for joining our  app.'),
    Notification(title: 'New Feature', message: 'Check out the new feature in the latest update.'),
    // Add more sample notifications here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(notification.message),
            trailing: IconButton(
              icon: Icon(
                notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                color: notification.isRead ? Colors.grey : Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  notification.isRead = !notification.isRead;
                });
              },
            ),
            onLongPress: () {
              setState(() {
                notifications.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}
