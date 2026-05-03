import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../widgets/glass_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _filterType = "Expense";

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    String name = "";
    String icon = "📦";
    String type = _filterType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Category Name (e.g. Health)"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => icon = val,
              decoration: const InputDecoration(labelText: "Icon (Emoji)"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              dropdownColor: SashTheme.backgroundDark,
              onChanged: (val) => type = val!,
              items: ["Expense", "Income"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              decoration: const InputDecoration(labelText: "Category Type"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await DatabaseHelper.instance.insertCategory(
                      CategoryModel(name: name, icon: icon, type: type)
                    );
                    Navigator.pop(context);
                    _loadCategories();
                  }
                },
                child: const Text("Create Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final filteredCategories = _categories.where((c) => c.type == _filterType).toList();

    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Manage Categories", style: TextStyle(fontFamily: 'Outfit')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildFilterChip("Expense"),
                const SizedBox(width: 12),
                _buildFilterChip("Income"),
                const Spacer(),
                IconButton(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add_circle, color: SashTheme.primary, size: 32),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                return _buildCategoryItem(cat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filterType = label),
      selectedColor: SashTheme.primary,
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildCategoryItem(CategoryModel cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            IconButton(
              onPressed: () async {
                if (cat.id != null) {
                  await DatabaseHelper.instance.deleteCategory(cat.id!);
                  _loadCategories();
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
