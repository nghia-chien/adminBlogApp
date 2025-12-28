import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import 'package:flutter/foundation.dart';
class ApiService {
  static String get baseUrl {
    if (Platform.isWindows || kIsWeb) {
      // Flutter Web
      return 'http://localhost:8080/BlogApp/index.php';
    } else {
      // Android emulator / device
      return 'http://10.0.2.2:8080/BlogApp/index.php';
    }
  }

  static Future<List<Article>> getArticles() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?path=articles'));
      
      if (res.statusCode != 200) {
        print('Error: HTTP ${res.statusCode} - ${res.body}');
        return [];
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      
      // Kiểm tra response format
      if (!body.containsKey('data') || !body.containsKey('success')) {
        print('Error: Invalid response format - ${res.body}');
        return [];
      }

      // Nếu không có data hoặc data không phải là list
      if (body['data'] == null || body['data'] is! List) {
        return [];
      }

      return (body['data'] as List)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }

  static Future<bool> createArticle(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl?path=articles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  static Future<bool> updateArticle(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl?path=articles&id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (res.statusCode != 200) {
        print('Error updating article: HTTP ${res.statusCode} - ${res.body}');
        return false;
      }

      return true;
    } catch (e) {
      print('Error updating article: $e');
      return false;
    }
  }


  static Future<bool> deleteArticle(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl?path=articles&id=$id'),
    );
    return res.statusCode == 200;
  }
}
