class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String author;

  var views;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'author': author,
    };
  }
}
