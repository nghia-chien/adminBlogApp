import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onChanged,
    this.isRequired = false,
  });

  static const List<Map<String, String>> categories = [
    {'id': 'Công nghệ', 'icon': '💻'},
    {'id': 'Kinh doanh', 'icon': '💼'},
    {'id': 'Giáo dục', 'icon': '📚'},
    {'id': 'Sức khỏe', 'icon': '🏥'},
    {'id': 'Lối sống', 'icon': '🌟'},
    {'id': 'Du lịch', 'icon': '✈️'},
    {'id': 'Ẩm thực', 'icon': '🍽️'},
    {'id': 'Thể thao', 'icon': '⚽'},
    {'id': 'Giải trí', 'icon': '🎬'},
    {'id': 'Tin tức', 'icon': '📰'},
    {'id': 'Khoa học', 'icon': '🔬'},
    {'id': 'Nghệ thuật', 'icon': '🎨'},
    {'id': 'Âm nhạc', 'icon': '🎵'},
    {'id': 'Thời trang', 'icon': '👗'},
    {'id': 'Khác', 'icon': '📂'},
  ];

  static String? getIcon(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return null;
    try {
      return categories.firstWhere(
        (cat) => cat['id'] == categoryName,
        orElse: () => {'id': categoryName, 'icon': '📂'},
      )['icon'];
    } catch (e) {
      return '📂';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory?.isEmpty == true ? null : selectedCategory,
      decoration: InputDecoration(
        labelText: 'Danh mục${isRequired ? ' *' : ''}',
        hintText: 'Chọn danh mục',
        prefixIcon: const Icon(Icons.category_rounded),
      ),
      items: [
        if (!isRequired)
          const DropdownMenuItem<String>(
            value: null,
            child: Row(
              children: [
                Text('📂'),
                SizedBox(width: 12),
                Text('Chưa chọn'),
              ],
            ),
          ),
        ...categories.map((category) {
          return DropdownMenuItem<String>(
            value: category['id'],
            child: Row(
              children: [
                Text(category['icon']!),
                const SizedBox(width: 12),
                Text(category['id']!),
              ],
            ),
          );
        }),
      ],
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn danh mục';
              }
              return null;
            }
          : null,
    );
  }
}

