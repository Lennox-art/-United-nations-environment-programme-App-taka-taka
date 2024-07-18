
class PostsModel {
  final String id;
  final String postedByDisplayName;
  final DateTime createdAt;
  final String content;
  final String imageUrl;
  final List<String> votes;

  const PostsModel({
      required this.id,
      required this.postedByDisplayName,
      required this.createdAt,
      required this.content,
      required this.imageUrl,
       this.votes = const [],
      });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posted_by_display_name': postedByDisplayName,
      'created_at': createdAt.toIso8601String(),
      'content': content,
      'image_url': imageUrl,
      'votes': votes,
    };
  }

  factory PostsModel.fromJson(Map<String, dynamic> json) {
    return PostsModel(
      id: json['id'],
      postedByDisplayName: json['posted_by_display_name'],
      createdAt: DateTime.parse(json['created_at']),
      content: json['content'],
      imageUrl: json['image_url'],
      votes: List<String>.from(json['votes']),
    );
  }


}