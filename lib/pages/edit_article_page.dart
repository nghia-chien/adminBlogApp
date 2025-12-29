// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../widgets/image_picker_widget.dart';

class EditArticlePage extends StatefulWidget {
  final Article article;

  const EditArticlePage({super.key, required this.article});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _summary;
  late TextEditingController _content;
  late TextEditingController _author;
  String? _selectedCategory;
  String? _selectedImageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.article.title);
    _summary = TextEditingController(text: widget.article.summary);
    _content = TextEditingController(text: widget.article.content);
    _author = TextEditingController(text: widget.article.author);
    _selectedImageBase64 = widget.article.imageUrl;
    
    // Map giá trị category cũ sang giá trị mới hoặc set null nếu không khớp
    final category = widget.article.category;
    final validCategories = ['Technology', 'Business', 'Sports', 'Education'];
    
    if (category.isNotEmpty && validCategories.contains(category)) {
      _selectedCategory = category;
    } else {
      // Map các giá trị cũ sang giá trị mới
      final categoryMap = {
        'Công nghệ': 'Technology',
        'Kinh doanh': 'Business',
        'Thể thao': 'Sports',
        'Giáo dục': 'Education',
        'Technology': 'Technology',
        'Business': 'Business',
        'Sports': 'Sports',
        'Education': 'Education',
      };
      _selectedCategory = categoryMap[category];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _content.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService.updateArticle(widget.article.id, {
      'title': _title.text.trim(),
      'summary': _summary.text.trim(),
      'content': _content.text.trim(),
      'category': _selectedCategory ?? '',
      'author': _author.text.trim(),
      'imageUrl': _selectedImageBase64 ?? '',
      // Views không được phép sửa - sẽ giữ nguyên giá trị cũ
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cập nhật bài viết thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Không thể cập nhật bài viết. Vui lòng thử lại.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Bài Viết',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Thông tin bài viết',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                hintText: 'Nhập tiêu đề bài viết',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _summary,
              decoration: const InputDecoration(
                labelText: 'Tóm tắt',
                hintText: 'Nhập tóm tắt ngắn gọn về bài viết',
                prefixIcon: Icon(Icons.short_text_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _content,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                hintText: 'Nhập nội dung chi tiết của bài viết',
                prefixIcon: Icon(Icons.article_rounded),
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                hintText: 'Chọn danh mục',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: null,
                  child: Row(
                    children: [
                      Text('📂'),
                      SizedBox(width: 12),
                      Text('Chưa chọn'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'Technology',
                  child: Row(
                    children: [
                      Text('💻'),
                      SizedBox(width: 12),
                      Text('Technology'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'Business',
                  child: Row(
                    children: [
                      Text('💼'),
                      SizedBox(width: 12),
                      Text('Business'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'Sports',
                  child: Row(
                    children: [
                      Text('⚽'),
                      SizedBox(width: 12),
                      Text('Sports'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'Education',
                  child: Row(
                    children: [
                      Text('📚'),
                      SizedBox(width: 12),
                      Text('Education'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _author,
              decoration: const InputDecoration(
                labelText: 'Tác giả',
                hintText: 'Tên tác giả',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị views nhưng không cho phép chỉnh sửa (read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.visibility_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lượt xem',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.article.views}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Hình ảnh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              initialImageUrl: _selectedImageBase64,
              onImageSelected: (base64) {
                setState(() {
                  _selectedImageBase64 = base64;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _update,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded),
                          SizedBox(width: 8),
                          Text(
                            'Lưu Thay Đổi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
