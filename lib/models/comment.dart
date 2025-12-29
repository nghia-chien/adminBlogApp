class Comment {
  final String id;
  final String articleId;
  final String userId;
  final String userName;
  final String content;
  final String createdAt;

  Comment({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      articleId: json['articleId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'created_at': createdAt,
    };
  }
}

