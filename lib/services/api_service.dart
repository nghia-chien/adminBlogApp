import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String BASE_URL =
      'http://localhost:8080/blogapp/index.php';

  static Future<List<Article>> getArticles() async {
    final res = await http.get(Uri.parse('$BASE_URL?path=articles'));
    final body = jsonDecode(res.body);

    return (body['data'] as List)
        .map((e) => Article.fromJson(e))
        .toList();
  }

  static Future<bool> createArticle(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$BASE_URL?path=articles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  static Future<bool> updateArticle(String id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$BASE_URL?path=articles&id=$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteArticle(String id) async {
    final res = await http.delete(
      Uri.parse('$BASE_URL?path=articles&id=$id'),
    );
    return res.statusCode == 200;
  }
}
