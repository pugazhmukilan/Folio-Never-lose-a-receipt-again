import 'package:flutter/material.dart';
import '../../data/models/category.dart';
import '../../data/database/database_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _dbHelper.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _showAddEditDialog({Category? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.iconName ?? 'category';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: _availableIcons.map((iconData) {
                      final isSelected = selectedIcon == iconData['name'];
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = iconData['name'] as String;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : null,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            iconData['icon'] as IconData,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a category name')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'name': name,
                  'iconName': selectedIcon,
                });
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        if (isEditing) {
          final updatedCategory = category.copyWith(
            name: result['name'],
            iconName: result['iconName'],
          );
          await _dbHelper.updateCategory(updatedCategory);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category updated successfully')),
            );
          }
        } else {
          final newCategory = Category(
            name: result['name'],
            iconName: result['iconName'],
            isSystem: false,
            isRentalType: false,
          );
          await _dbHelper.insertCategory(newCategory);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category added successfully')),
            );
          }
        }
        _loadCategories();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final productCount = await _dbHelper.getProductCountByCategory(category.name);
    
    if (productCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delete: $productCount product(s) use this category'),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteCategory(category.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        }
        _loadCategories();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final icon = _getIconFromName(category.iconName);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Icon(icon, color: Theme.of(context).primaryColor),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              if (category.isSystem)
                                const Chip(
                                  label: Text('System', style: TextStyle(fontSize: 10)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (category.isRentalType)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Chip(
                                    label: Text('Rental', style: TextStyle(fontSize: 10)),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                            ],
                          ),
                          trailing: category.isSystem
                              ? const Icon(Icons.lock_outline, color: Colors.grey)
                              : PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showAddEditDialog(category: category);
                                    } else if (value == 'delete') {
                                      _deleteCategory(category);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      for (var item in _availableIcons) item['name']: item['icon']
    };
    return iconMap[iconName] as IconData? ?? Icons.category;
  }

  static final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'category', 'icon': Icons.category},
    {'name': 'devices', 'icon': Icons.devices},
    {'name': 'kitchen', 'icon': Icons.kitchen},
    {'name': 'weekend', 'icon': Icons.weekend},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'handyman', 'icon': Icons.handyman},
    {'name': 'yard', 'icon': Icons.yard},
    {'name': 'checkroom', 'icon': Icons.checkroom},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer},
    {'name': 'menu_book', 'icon': Icons.menu_book},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'computer', 'icon': Icons.computer},
    {'name': 'phone_android', 'icon': Icons.phone_android},
    {'name': 'camera', 'icon': Icons.camera_alt},
    {'name': 'watch', 'icon': Icons.watch},
    {'name': 'headphones', 'icon': Icons.headphones},
    {'name': 'tv', 'icon': Icons.tv},
    {'name': 'games', 'icon': Icons.sports_esports},
    {'name': 'fitness', 'icon': Icons.fitness_center},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'local_cafe', 'icon': Icons.local_cafe},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'medical', 'icon': Icons.medical_services},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'child_care', 'icon': Icons.child_care},
    {'name': 'music', 'icon': Icons.music_note},
    {'name': 'palette', 'icon': Icons.palette},
    {'name': 'build', 'icon': Icons.build},
    {'name': 'brush', 'icon': Icons.brush},
    {'name': 'extension', 'icon': Icons.extension},
  ];
}

