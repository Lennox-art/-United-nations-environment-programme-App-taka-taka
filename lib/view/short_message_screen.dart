import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:food/model/models.dart';

/*
class ShortMessageScreen extends StatefulWidget {
  @override
  _ShortMessageScreenState createState() => _ShortMessageScreenState();
}

class _ShortMessageScreenState extends State<ShortMessageScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Short Message/Image'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestoreService.getShortMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var messages = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return ShortMessage(
              id: doc.id,
              content: data['content'],
              imageUrl: data['imageUrl'],
            );
          }).toList();

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return ListTile(
                title: Text(message.content),
                leading: message.imageUrl != null
                    ? Image.network(message.imageUrl)
                    : null,
                trailing: ElevatedButton(
                  onPressed: () {
                    _showRecipientSearchModal(context, message);
                  },
                  child: Text('Share'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecipientSearchModal(BuildContext context, ShortMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return RecipientSearchModal(
          onRecipientSelected: (recipient) {
            _sendMessage(recipient, message);
          },
        );
      },
    );
  }

  void _sendMessage(String recipient, ShortMessage message) {
    _firestoreService.sendMessage(recipient, message).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message sent successfully!'),
      ));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message: $e'),
      ));
    });
  }
}

class RecipientSearchModal extends StatefulWidget {
  final Function(String) onRecipientSelected;

  const RecipientSearchModal({required this.onRecipientSelected});

  @override
  _RecipientSearchModalState createState() => _RecipientSearchModalState();
}

class _RecipientSearchModalState extends State<RecipientSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search for recipient',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: _firestoreService.searchUsers(_searchController.text),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              var users = snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return User(
                  id: doc.id,
                  displayName: data['displayName'],
                );
              }).toList();

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return ListTile(
                    title: Text(user.displayName),
                    onTap: () {
                      widget.onRecipientSelected(user.id);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
*/