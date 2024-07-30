import 'package:flutter/material.dart';
import 'models.dart';
import 'services.dart';
import 'widgets.dart';

class MessageShareScreen extends StatelessWidget {
  final List<Message> messages = [
    Message(content: 'Preselected message 1', isImage: false),
    Message(content: 'https://via.placeholder.com/150', isImage: true),
    // Add more messages and images
  ];

  void _showUserSearch(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return UserSearchModule(onUserSelected: (User user) {
          sendMessage(user.userId, message);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message sent to ${user.username}')));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share Messages & Images')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageWidget(
            message: message,
            onShare: () => _showUserSearch(context, message),
          );
        },
      ),
    );
  }
}

class UserSearchModule extends StatefulWidget {
  final Function(User) onUserSelected;

  UserSearchModule({required this.onUserSelected});

  @override
  _UserSearchModuleState createState() => _UserSearchModuleState();
}

class _UserSearchModuleState extends State<UserSearchModule> {
  List<User> _users = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    fetchUsers().then((users) {
      setState(() {
        _users = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((user) => user.username.contains(_searchText)).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Search Users'),
          onChanged: (text) {
            setState(() {
              _searchText = text;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return ListTile(
                title: Text(user.username),
                onTap: () => widget.onUserSelected(user),
              );
            },
          ),
        ),
      ],
    );
  }
}
