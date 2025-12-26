import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({super.key});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _content = TextEditingController();
  final _category = TextEditingController();
  final _author = TextEditingController();
  final _views = TextEditingController();

  Future<void> _submit() async {
    if (_title.text.isEmpty) return;

    await ApiService.createArticle({
      'title': _title.text,
      'summary': _summary.text,
      'content': _content.text,
      'category': _category.text,
      'author': _author.text,
      'views': _views.text,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Article')),
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
            ElevatedButton(onPressed: _submit, child: const Text('Create')),
          ],
        ),
      ),
    );
  }
}
