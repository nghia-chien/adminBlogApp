import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/article.dart';
import '../models/user.dart' as models;
import '../services/api_service.dart';

class CommentListPage extends StatefulWidget {
  const CommentListPage({super.key});

  @override
  State<CommentListPage> createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  late Future<List<Comment>> _future;
  Map<String, Article> _articlesMap = {};
  Map<String, models.User> _usersMap = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _future = _loadCommentsWithDetails();
    });
  }

  Future<List<Comment>> _loadCommentsWithDetails() async {
    // Load articles và users để map
    final articles = await ApiService.getArticles();
    final users = await ApiService.getAllUsers();
    
    setState(() {
      _articlesMap = {for (var a in articles) a.id: a};
      _usersMap = {for (var u in users) u.id: u};
    });
    
    return await ApiService.getAllComments();
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteComment(comment.id, comment.articleId);
      if (success) {
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa bình luận'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể xóa bình luận'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Bình Luận'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: FutureBuilder<List<Comment>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final comments = snapshot.data ?? [];

          if (comments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.comment_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bình luận nào',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _load();
              await _future;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(comment.userName.isNotEmpty
                                  ? comment.userName[0].toUpperCase()
                                  : 'U'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _usersMap[comment.userId]?.name ?? comment.userId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _articlesMap[comment.articleId]?.title ?? 
                                'Bài: ${comment.articleId.substring(0, 8)}...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteComment(comment),
                              tooltip: 'Xóa bình luận',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(comment.content),
                        const SizedBox(height: 8),
                        Text(
                          comment.createdAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

