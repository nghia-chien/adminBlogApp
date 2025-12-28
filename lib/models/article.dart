class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String author;
  final int views;
  final String? imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.author,
    required this.views,
    this.imageUrl,
  });


  factory Article.fromJson(Map<String, dynamic> json) {
    // Parse views: có thể là int, string, hoặc null
    int viewsValue = 0;
    if (json['views'] != null) {
      if (json['views'] is int) {
        viewsValue = json['views'];
      } else if (json['views'] is String) {
        viewsValue = int.tryParse(json['views']) ?? 0;
      }
    }

    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      author: json['author'] ?? '',
      views: viewsValue,
      imageUrl: json['imageUrl'], // Backend trả về imageUrl (camelCase)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'author': author,
      'views': views,
      'imageUrl': imageUrl, // Sử dụng camelCase để khớp với backend
    };
  }
}
