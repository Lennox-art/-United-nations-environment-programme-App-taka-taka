enum AdminPostType {
  estimation('Estimate Post'),
  congratulatory('Congratulatory Post');

  final String value;

  const AdminPostType(this.value);
}

class UserPostsModel {
  final String id;
  final String postedByUserId;
  final DateTime createdAt;
  final String content;
  final String imageUrl;
  final List<String> votes;

  const UserPostsModel({
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

  @override
  String toString() => toJson().toString();

  factory UserPostsModel.fromJson(Map<String, dynamic> json) {
    return UserPostsModel(
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
      role: UserRoles.values.firstWhere((e) => json['role'] == e.name),
      photoUrl: json['photo_url'] as String?,
      displayName: json['display_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

const List<UserRoles> allRoles = UserRoles.values;

enum UserRoles { user, admin }

enum Metric { kgs, tonnes }

class PollData {
  String userId;
  double value;
  DateTime timestamp;
  Metric metric;

  PollData({
    required this.userId,
    required this.value,
    required this.timestamp,
    required this.metric,
  });

  // Convert a PollData object into a map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'metric': metric.toString().split('.').last,
    };
  }

  // Convert a map into a PollData object
  factory PollData.fromJson(Map<String, dynamic> json) {
    return PollData(
      userId: json['userId'],
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      metric: Metric.values.firstWhere((e) => e.toString().split('.').last == json['metric']),
    );
  }

  @override
  String toString() => toJson().toString();
}

class AdminPost {
  String id;
  String content;
  String postedBy;
  AdminPostType postType; // 'Estimate Post' or 'Congratulatory Post'
  Map<String, PollData> userPollData; // User estimates in kgs/tonnes
  List<UserComment> comments;
  DateTime postedAt;

  AdminPost({
    required this.id,
    required this.content,
    required this.postedBy,
    required this.postType,
    required this.userPollData,
    required this.comments,
    required this.postedAt,
  });

  // Convert an AdminPost object into a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'post_type': postType.name,
      'posted_by': postedBy,
      'user_poll_data': userPollData.map((key, value) => MapEntry(key, value.toJson())),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'posted_at': postedAt.toIso8601String(),
    };
  }

  @override
  String toString() => toJson().toString();

  // Convert a map into an AdminPost object
  factory AdminPost.fromJson(Map<String, dynamic> json) {
    return AdminPost(
      id: json['id'],
      content: json['content'],
      postType: AdminPostType.values.firstWhere((e) => json['post_type'] == e.name),
      postedAt: DateTime.parse(json['posted_at']),
      postedBy: json['posted_by'],
      userPollData: (json['user_poll_data'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, PollData.fromJson(value))),
      comments: (json['comments'] as List)
          .map((commentJson) => UserComment.fromJson(commentJson))
          .toList(),
    );
  }
}

class UserComment {
  String userId;
  String comment;
  DateTime timestamp;

  UserComment({
    required this.userId,
    required this.comment,
    required this.timestamp,
  });

  // Convert a UserComment object into a map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a map into a UserComment object
  factory UserComment.fromJson(Map<String, dynamic> json) {
    return UserComment(
      userId: json['userId'],
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
