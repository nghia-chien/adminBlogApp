import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class EditArticlePage extends StatefulWidget {
  final Article article;

  const EditArticlePage({super.key, required this.article});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  late TextEditingController _title;
  late TextEditingController _summary;
  late TextEditingController _content;
  late TextEditingController _category;
  late TextEditingController _author;
  late TextEditingController _views;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.article.title);
    _summary = TextEditingController(text: widget.article.summary);
    _content = TextEditingController(text: widget.article.content);
    _category = TextEditingController(text: widget.article.category);
    _author = TextEditingController(text: widget.article.author);
    _views = TextEditingController(text: widget.article.views);
  }

  Future<void> _update() async {
    await ApiService.updateArticle(widget.article.id, {
      'title': _title.text,
      'summary': _summary.text,
      'content': _content.text,
      'category': _category.text,
      'author': _author.text,
      'views': _views.text,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Article')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _summary, decoration: const InputDecoration(labelText: 'Summary')),
            TextField(controller: _content, decoration: const InputDecoration(labelText: 'Content'), maxLines: 5),
            TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: _author, decoration: const InputDecoration(labelText: 'Author')),
            TextField(controller: _views, decoration: const InputDecoration(labelText: 'Views')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: const Text('Update')),
          ],
        ),
      ),
    );
  }
}
