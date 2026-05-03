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
  Map<String, dynamic>? _selectedAccount;
  List<CategoryModel> _categories = [];
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = DatabaseHelper.instance;
    final categories = await db.getCategories();
    final accounts = await db.getAccounts();
    
    setState(() {
      _categories = categories;
      _accounts = accounts;
      if (accounts.isNotEmpty) _selectedAccount = accounts.first;
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
    if (_selectedAccount == null) return;

    final transaction = TransactionModel(
      accountId: _selectedAccount!['id'],
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
          const SizedBox(height: 24),
          _buildAccountSelector(),
          const SizedBox(height: 24),
          _buildTypeToggle(),
          const SizedBox(height: 24),
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

  Widget _buildAccountSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _accounts.map((acc) {
          final isSelected = _selectedAccount?['id'] == acc['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedAccount = acc),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? SashTheme.primary : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? SashTheme.primary : Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(
                    acc['type'] == 'Wallet' ? Icons.payments : Icons.account_balance,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    acc['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
