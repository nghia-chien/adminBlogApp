class Like {
  final String id;
  final String userId;
  final String articleId;
  final String createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      articleId: json['articleId'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'articleId': articleId,
      'created_at': createdAt,
    };
  }
}

