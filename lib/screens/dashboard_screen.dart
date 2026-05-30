import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../database/database_helper.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int refreshTrigger;
  const DashboardScreen({super.key, this.refreshTrigger = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalBalance = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  List<Map<String, dynamic>> _budgets = [];
  String _familyName = "Household";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    final db = DatabaseHelper.instance;
    final balance = await db.getTotalBalance();
    final transactions = await db.getRecentTransactions(limit: 10);
    final family = await db.getFamily();
    final budgets = await db.getCategorySpendingWithBudgets();

    setState(() {
      _totalBalance = balance;
      _recentTransactions = transactions;
      _familyName = family?['name'] ?? "Household";
      _budgets = budgets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildBalanceCard(),
                if (_budgets.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text("Budget Health", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  const SizedBox(height: 16),
                  _buildBudgetHealth(),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: SashTheme.primary))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTransactionList(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back,", style: TextStyle(color: Colors.white60, fontSize: 14)),
            Text(_familyName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          ],
        ),
        const CircleAvatar(
          backgroundColor: SashTheme.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL BALANCE", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text("₹${_totalBalance.toStringAsFixed(2)}", 
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBalanceDetail("Income", "₹0.00", SashTheme.accent),
              const SizedBox(width: 40),
              _buildBalanceDetail("Expense", "₹0.00", SashTheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBudgetHealth() {
    return Column(
      children: _budgets.map((b) {
        final limit = (b['budget_limit'] as num).toDouble();
        final spent = (b['total'] as num).toDouble();
        final percentage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
        final isOverBudget = percentage >= 1.0;
        final isWarning = percentage >= 0.8 && !isOverBudget;
        
        Color progressColor = SashTheme.primary;
        if (isOverBudget) progressColor = SashTheme.error;
        else if (isWarning) progressColor = Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(b['icon'] ?? '📦', style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(b['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text("₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? SashTheme.error : Colors.white,
                      )),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList() {
    if (_recentTransactions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text("No transactions yet. Tap + to start!", style: TextStyle(color: Colors.white24)),
      ));
    }
    return Column(
      children: _recentTransactions.map((t) => _buildTransactionItem(t)).toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(existingTransaction: t),
            ),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(t['category_icon'] ?? "💰", style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['category_name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(t['account_name'] ?? "Cash", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "${t['type'] == 'Credit' ? '+' : '-'}₹${(t['amount'] as num).toStringAsFixed(0)}",
                style: TextStyle(
                  color: t['type'] == 'Credit' ? SashTheme.accent : SashTheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
