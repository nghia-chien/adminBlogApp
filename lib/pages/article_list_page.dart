import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import 'create_article_page.dart';
import 'edit_article_page.dart';

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
    _future = ApiService.getArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticlePage()),
          );
          setState(_load);
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles'));
          }

          final articles = snapshot.data!;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (_, i) {
              final a = articles[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(a.title),
                  subtitle: Text(a.summary, maxLines: 2),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditArticlePage(article: a),
                            ),
                          );
                          setState(_load);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await ApiService.deleteArticle(a.id);
                          setState(_load);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
