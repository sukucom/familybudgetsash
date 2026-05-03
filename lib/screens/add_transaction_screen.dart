import 'package:flutter/material.dart';
import '../widgets/sash_keypad.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _amount = "0";
  bool _isDebit = true;
  String _selectedCategory = "Food";

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

  void _handleSave() {
    // Show success snackbar or animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Nice! ₹$_amount logged 🔥"),
        backgroundColor: SashTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
      onTap: () => setState(() => _isDebit = label == "Debit"),
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
    final categories = ["Food", "Travel", "Rent", "Shopping", "Bills"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(cat),
            selected: _selectedCategory == cat,
            onSelected: (val) => setState(() => _selectedCategory = cat),
            selectedColor: SashTheme.primary,
            backgroundColor: Colors.white10,
            labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.white70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )).toList(),
      ),
    );
  }
}
