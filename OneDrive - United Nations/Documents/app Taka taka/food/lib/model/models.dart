
class PostsModel {
  final String id;
  final String postedByUserId;
  final DateTime createdAt;
  final String content;
  final String imageUrl;
  final List<String> votes;

  const PostsModel({
      required this.id,
      required this.postedByUserId,
      required this.createdAt,
      required this.content,
      required this.imageUrl,
       this.votes = const [],
      });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posted_by_user_id': postedByUserId,
      'created_at': createdAt.toIso8601String(),
      'content': content,
      'image_url': imageUrl,
      'votes': votes,
    };
  }

  factory PostsModel.fromJson(Map<String, dynamic> json) {
    return PostsModel(
      id: json['id'],
      postedByUserId: json['posted_by_user_id'],
      createdAt: DateTime.parse(json['created_at']),
      content: json['content'],
      imageUrl: json['image_url'],
      votes: List<String>.from(json['votes']),
    );
  }


}

class User {
  final String id;
  UserRoles role;
  String? photoUrl;
  String displayName;
  final DateTime createdAt;

  User({
    required this.id,
    required this.role,
    this.photoUrl,
    required this.displayName,
    required this.createdAt,
  });

  // Convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'photo_url': photoUrl,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      role: UserRoles.values.where((e) => json['role'] == e.name).first,
      photoUrl: json['photo_url'] as String?,
      displayName: json['display_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

const List<UserRoles> allRoles = UserRoles.values;

enum UserRoles {
  user, admin
}