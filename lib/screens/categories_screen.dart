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

  void _showAddOrEditCategoryDialog([CategoryModel? existingCat]) {
    String name = existingCat?.name ?? "";
    String icon = existingCat?.icon ?? "📦";
    String type = existingCat?.type ?? _filterType;
    double budgetLimit = existingCat?.budgetLimit ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existingCat == null ? "Add New Category" : "Edit Category", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: name),
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Category Name (e.g. Health)"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: icon),
              onChanged: (val) => icon = val,
              decoration: const InputDecoration(labelText: "Icon (Emoji)"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            if (type == "Expense")
              TextField(
                controller: TextEditingController(text: budgetLimit > 0 ? budgetLimit.toString() : ""),
                onChanged: (val) => budgetLimit = double.tryParse(val) ?? 0.0,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Monthly Budget Limit (₹)", hintText: "0.00 for no limit"),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            if (type == "Expense") const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
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
                    final newCat = CategoryModel(
                      id: existingCat?.id,
                      name: name, 
                      icon: icon, 
                      type: type,
                      budgetLimit: type == "Expense" ? budgetLimit : 0.0,
                    );
                    if (existingCat != null) {
                      await DatabaseHelper.instance.updateCategory(newCat);
                    } else {
                      await DatabaseHelper.instance.insertCategory(newCat);
                    }
                    if (context.mounted) Navigator.pop(context);
                    _loadCategories();
                  }
                },
                child: Text(existingCat == null ? "Create Category" : "Save Changes"),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  onPressed: () => _showAddOrEditCategoryDialog(),
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
      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (cat.type == 'Expense' && cat.budgetLimit > 0)
                    Text("Budget: ₹${cat.budgetLimit.toStringAsFixed(0)}", 
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showAddOrEditCategoryDialog(cat),
              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), size: 20),
            ),
            IconButton(
              onPressed: () async {
                if (cat.id != null) {
                  await DatabaseHelper.instance.deleteCategory(cat.id!);
                  _loadCategories();
                }
              },
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
