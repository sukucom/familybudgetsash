import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';
import '../models/category_model.dart';
import 'package:intl/intl.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  List<Map<String, dynamic>> _recurringList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await DatabaseHelper.instance.getRecurringTransactions();
    setState(() {
      _recurringList = list;
      _isLoading = false;
    });
  }

  void _showAddDialog() async {
    final db = DatabaseHelper.instance;
    final accounts = await db.getAccounts();
    final members = await db.getMembers();
    final categories = await db.getCategories();

    if (accounts.isEmpty || members.isEmpty || categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please ensure you have accounts, members, and categories set up first."))
        );
      }
      return;
    }

    String amount = "";
    String type = "Expense";
    String frequency = "Monthly";
    DateTime nextDate = DateTime.now();
    int selectedAccountId = accounts.first['id'];
    int selectedMemberId = members.first['id'];
    int? selectedCategoryId = categories.firstWhere((c) => c.type == type, orElse: () => categories.first).id;
    String note = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return GlassCard(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Recurring Bill", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (val) => amount = val,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount (₹)"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: SashTheme.backgroundDark,
                    onChanged: (val) {
                      setModalState(() {
                        type = val!;
                        selectedCategoryId = categories.firstWhere((c) => c.type == type, orElse: () => categories.first).id;
                      });
                    },
                    items: ["Expense", "Income"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    decoration: const InputDecoration(labelText: "Type"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    dropdownColor: SashTheme.backgroundDark,
                    onChanged: (val) => selectedCategoryId = val,
                    items: categories.where((c) => c.type == type).map((c) => DropdownMenuItem<int>(value: c.id, child: Text("${c.icon} ${c.name}"))).toList(),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    dropdownColor: SashTheme.backgroundDark,
                    onChanged: (val) => frequency = val!,
                    items: ["Daily", "Weekly", "Monthly", "Yearly"].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    decoration: const InputDecoration(labelText: "Frequency"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedAccountId,
                    dropdownColor: SashTheme.backgroundDark,
                    onChanged: (val) => selectedAccountId = val!,
                    items: accounts.map((a) => DropdownMenuItem<int>(value: a['id'], child: Text(a['name']))).toList(),
                    decoration: const InputDecoration(labelText: "Charge To Account"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Next Billing Date: ", style: TextStyle(color: Colors.white60)),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: nextDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setModalState(() => nextDate = date);
                          }
                        },
                        child: Text(DateFormat('MMM dd, yyyy').format(nextDate), style: const TextStyle(color: SashTheme.accent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => note = val,
                    decoration: const InputDecoration(labelText: "Note (Optional)"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amount.isNotEmpty) {
                          await DatabaseHelper.instance.insertRecurringTransaction({
                            'account_id': selectedAccountId,
                            'member_id': selectedMemberId,
                            'category_id': selectedCategoryId ?? 1,
                            'amount': double.tryParse(amount) ?? 0,
                            'type': type == 'Income' ? 'Credit' : 'Debit',
                            'note': note,
                            'frequency': frequency,
                            'next_date': nextDate.toIso8601String(),
                          });
                          if (context.mounted) Navigator.pop(context);
                          _loadData();
                        }
                      },
                      child: const Text("Save Subscription"),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Manage Subscriptions", style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: SashTheme.primary, size: 32),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _recurringList.isEmpty
          ? const Center(child: Text("No recurring bills set up.", style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _recurringList.length,
              itemBuilder: (context, index) {
                final r = _recurringList[index];
                final nextDate = DateTime.parse(r['next_date']);
                final isCredit = r['type'] == 'Credit';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(r['category_icon'] ?? "📦", style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['category_name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("${r['frequency']} • Next: ${DateFormat('MMM dd').format(nextDate)}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${isCredit ? '+' : '-'}₹${(r['amount'] as num).toStringAsFixed(0)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isCredit ? SashTheme.accent : SashTheme.error,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteRecurringTransaction(r['id']);
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
