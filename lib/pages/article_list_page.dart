// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import 'create_article_page.dart';
import 'edit_article_page.dart';
import '../widgets/article_image_widget.dart';
import '../widgets/category_selector.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late Future<List<Article>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ApiService.getArticles();
    });
  }

  Future<void> _deleteArticle(Article article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bài viết "${article.title}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteArticle(article.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Đã xóa bài viết thành công'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          _load();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Không thể xóa bài viết'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.article_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Quản Lý Bài Viết',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticlePage()),
          );
          _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo mới'),
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đã xảy ra lỗi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có bài viết nào',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy tạo bài viết đầu tiên của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateArticlePage(),
                          ),
                        );
                        _load();
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tạo bài viết mới'),
                    ),
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _load();
              await _future;
            },
            color: theme.colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (_, i) {
                final a = articles[i];
                return _buildArticleCard(context, theme, a);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ThemeData theme, Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditArticlePage(article: article),
            ),
          );
          _load();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: ArticleImageWidget(
                    imageUrl: article.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.summary.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.summary,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                      Row(
                        children: [
                          if (article.category.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    CategorySelector.getIcon(article.category) ?? '📂',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    article.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.views}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nút hành động
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditArticlePage(article: article),
                        ),
                      );
                      _load();
                    },
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    onPressed: () => _deleteArticle(article),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
