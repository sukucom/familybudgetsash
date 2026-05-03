import 'package:flutter/material.dart';
import '../widgets/sash_keypad.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _amount = "0";
  bool _isDebit = true;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      _selectedCategory = categories.firstWhere((c) => c.type == (_isDebit ? 'Expense' : 'Income'), orElse: () => categories.first);
      _isLoading = false;
    });
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (_amount == "0") {
        _amount = key;
      } else {
        _amount += key;
      }
    });
  }

  void _handleDelete() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = "0";
      }
    });
  }

  Future<void> _handleSave() async {
    if (_amount == "0") return;

    final db = DatabaseHelper.instance;
    final accounts = await db.getAccounts();
    if (accounts.isEmpty) return;

    final transaction = TransactionModel(
      accountId: accounts.first['id'], // Default to first account
      memberId: 1, // Default to first member
      categoryId: _selectedCategory?.id ?? 1,
      amount: double.parse(_amount),
      date: DateTime.now(),
      type: _isDebit ? 'Debit' : 'Credit',
    );

    await db.insertTransaction(transaction.toMap());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nice! ₹$_amount logged 🔥"),
          backgroundColor: SashTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate data changed
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Add Transaction", style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          _buildAmountDisplay(),
          const SizedBox(height: 40),
          _buildTypeToggle(),
          const SizedBox(height: 32),
          _buildCategoryChips(),
          const SizedBox(height: 32),
          SashKeypad(
            onKeyPressed: _handleKeyPress,
            onDelete: _handleDelete,
            onDone: _handleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        Text(
          _isDebit ? "Expense" : "Income",
          style: TextStyle(color: _isDebit ? SashTheme.error : SashTheme.accent, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text("₹", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white24)),
            ),
            Text(
              _amount,
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem("Debit", _isDebit, SashTheme.error),
          _buildToggleItem("Credit", !_isDebit, SashTheme.accent),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, Color activeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDebit = label == "Debit";
          // Update selected category based on type
          _selectedCategory = _categories.firstWhere(
            (c) => c.type == (_isDebit ? 'Expense' : 'Income'),
            orElse: () => _categories.first,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final filteredCategories = _categories.where((c) => c.type == (_isDebit ? 'Expense' : 'Income')).toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filteredCategories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text("${cat.icon} ${cat.name}"),
            selected: _selectedCategory?.id == cat.id,
            onSelected: (val) => setState(() => _selectedCategory = cat),
            selectedColor: SashTheme.primary,
            backgroundColor: Colors.white10,
            labelStyle: TextStyle(color: _selectedCategory?.id == cat.id ? Colors.white : Colors.white70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )).toList(),
      ),
    );
  }
}
