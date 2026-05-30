import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sash_keypad.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? existingTransaction;
  const AddTransactionScreen({super.key, this.existingTransaction});

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
  List<Map<String, dynamic>> _members = [];
  Map<String, dynamic>? _selectedMember;
  bool _isLoading = true;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = DatabaseHelper.instance;
    final categories = await db.getCategories();
    final accounts = await db.getAccounts();
    final members = await db.getMembers();
    
    setState(() {
      _categories = categories;
      _accounts = accounts;
      _members = members;
      
      if (_members.isNotEmpty) {
        _selectedMember = _members.firstWhere((m) => m['role'] == 'Admin', orElse: () => _members.first);
      }
      
      if (widget.existingTransaction != null) {
        final tx = widget.existingTransaction!;
        _amount = (tx['amount'] as num).toStringAsFixed(0);
        _isDebit = tx['type'] == 'Debit';
        _noteController.text = tx['note'] ?? "";
        _selectedAccount = accounts.firstWhere((a) => a['id'] == tx['account_id'], orElse: () => accounts.first);
        _selectedMember = members.firstWhere((m) => m['id'] == tx['member_id'], orElse: () => members.first);
        _selectedCategory = categories.firstWhere((c) => c.id == tx['category_id'], orElse: () => categories.first);
      } else {
        if (accounts.isNotEmpty) _selectedAccount = accounts.first;
        _selectedCategory = categories.firstWhere((c) => c.type == (_isDebit ? 'Expense' : 'Income'), orElse: () => categories.first);
      }
      _isLoading = false;
    });
  }

  void _onKeyPress(String value) {
    setState(() {
      if (value == ".") {
        if (!_amount.contains(".")) {
          _amount += ".";
        }
      } else {
        if (_amount == "0") {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = "0";
      }
    });
  }

  Future<void> _saveTransaction() async {
    if (_amount == "0") return;

    final db = DatabaseHelper.instance;
    if (_selectedAccount == null) return;

    final transactionData = {
      'account_id': _selectedAccount!['id'],
      'member_id': _selectedMember?['id'] ?? 1,
      'category_id': _selectedCategory?.id ?? 1,
      'amount': double.parse(_amount),
      'date': widget.existingTransaction?['date'] ?? DateTime.now().toIso8601String(),
      'note': _noteController.text,
      'type': _isDebit ? 'Debit' : 'Credit',
    };

    if (widget.existingTransaction != null) {
      transactionData['id'] = widget.existingTransaction!['id'];
      await db.updateTransaction(transactionData);
    } else {
      await db.insertTransaction(transactionData);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteTransaction() async {
    if (widget.existingTransaction == null) return;
    
    final db = DatabaseHelper.instance;
    await db.deleteTransaction(widget.existingTransaction!['id']);
    
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.existingTransaction != null ? "Edit Transaction" : "New Entry", 
          style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          if (widget.existingTransaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: SashTheme.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: Text("Delete Transaction?", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    content: Text("This will revert the account balance changes.", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteTransaction();
                        }, 
                        child: const Text("Delete", style: TextStyle(color: SashTheme.error))
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          _buildAmountDisplay(),
          const SizedBox(height: 24),
          _buildAccountSelector(),
          const SizedBox(height: 16),
          _buildMemberSelector(),
          const SizedBox(height: 16),
          _buildTypeToggle(),
          const SizedBox(height: 16),
          _buildCategoryChips(),
          const SizedBox(height: 24),
          _buildNoteField(),
          const SizedBox(height: 32),
          SashKeypad(
            onKeyPressed: _onKeyPress,
            onDelete: _onDelete,
            onDone: _saveTransaction,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        Text("AMOUNT", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 12, letterSpacing: 2)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("₹", style: TextStyle(color: _isDebit ? SashTheme.error : SashTheme.accent, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(_amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          ],
        ),
      ],
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
                color: isSelected ? SashTheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? SashTheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.24)),
              ),
              child: Row(
                children: [
                  Icon(
                    acc['type'] == 'Wallet' ? Icons.payments : Icons.account_balance,
                    size: 16,
                    color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    acc['name'],
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildMemberSelector() {
    if (_members.isEmpty) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _members.map((mem) {
          final isSelected = _selectedMember?['id'] == mem['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedMember = mem),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? SashTheme.accent.withOpacity(0.2) : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? SashTheme.accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.24)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: isSelected ? SashTheme.accent : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mem['name'],
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildTypeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleItem("Debit", _isDebit, SashTheme.error)),
          Expanded(child: _buildToggleItem("Credit", !_isDebit, SashTheme.accent)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, Color activeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDebit = label == "Debit";
          _selectedCategory = _categories.firstWhere((c) => c.type == (_isDebit ? 'Expense' : 'Income'), orElse: () => _categories.first);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final filteredCategories = _categories.where((c) => c.type == (_isDebit ? 'Expense' : 'Income')).toList();
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final cat = filteredCategories[index];
          final isSelected = _selectedCategory?.id == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? SashTheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
              ),
              child: Center(child: Text("${cat.icon} ${cat.name}", style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _noteController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Add a note...",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          prefixIcon: Icon(Icons.notes, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
