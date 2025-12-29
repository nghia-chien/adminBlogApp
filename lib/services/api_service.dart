import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/like.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb ) {
      return 'http://localhost:8080/BlogApp1/index.php';
    } else {
      return 'http://10.0.2.2:8080/BlogApp1/index.php';
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

  // Admin APIs - Users
  static Future<User?> getUser(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?path=users&id=$id'));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return User.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?path=users&action=all'));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return (body['data'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  static Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl?path=users&id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl?path=users&id=$id'),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Admin APIs - Comments (lấy tất cả comments từ tất cả articles)
  static Future<List<Comment>> getAllComments() async {
    try {
      // Lấy tất cả articles trước
      final articles = await getArticles();
      final allComments = <Comment>[];

      // Lấy comments từ mỗi article
      for (final article in articles) {
        final res = await http.get(
          Uri.parse('$baseUrl?path=comments&articleId=${article.id}'),
        );
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] != null) {
            final comments = (body['data'] as List)
                .map((e) => Comment.fromJson(e as Map<String, dynamic>))
                .toList();
            allComments.addAll(comments);
          }
        }
      }

      return allComments;
    } catch (e) {
      print('Error fetching all comments: $e');
      return [];
    }
  }

  static Future<bool> deleteComment(String commentId, String articleId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl?path=comments&id=$commentId&articleId=$articleId'),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Admin APIs - Likes (lấy tất cả likes từ tất cả articles)
  static Future<List<Like>> getAllLikes() async {
    try {
      // Lấy tất cả articles trước
      final articles = await getArticles();
      final allLikes = <Like>[];

      // Lấy likes từ mỗi article
      for (final article in articles) {
        final res = await http.get(
          Uri.parse('$baseUrl?path=likes&articleId=${article.id}'),
        );
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] != null) {
            final likes = (body['data'] as List)
                .map((e) => Like.fromJson({
                      ...e as Map<String, dynamic>,
                      'articleId': article.id,
                    }))
                .toList();
            allLikes.addAll(likes);
          }
        }
      }

      return allLikes;
    } catch (e) {
      print('Error fetching all likes: $e');
      return [];
    }
  }

  static Future<bool> deleteLike(String likeId, String articleId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl?path=likes&id=$likeId&articleId=$articleId'),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleting like: $e');
      return false;
    }
  }
}
