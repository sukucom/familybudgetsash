import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalBalance = 0.0;
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final db = DatabaseHelper.instance;
    final balance = await db.getTotalBalance();
    final accounts = await db.getAccounts();
    final transactions = await db.getRecentTransactions();

    setState(() {
      _totalBalance = balance;
      _accounts = accounts;
      _recentTransactions = transactions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
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
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 32),
                _buildSectionHeader("My Accounts"),
                const SizedBox(height: 16),
                _buildAccountStrip(),
                const SizedBox(height: 32),
                _buildSectionHeader("Daily Streak"),
                const SizedBox(height: 16),
                _buildStreakCard(),
                const SizedBox(height: 32),
                _buildSectionHeader("Recent Transactions"),
                const SizedBox(height: 16),
                _buildRecentTransactions(),
                const SizedBox(height: 100), // Spacing for FAB
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: TextStyle(color: Colors.white60)),
            Text("Sash Family", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          ],
        ),
        CircleAvatar(
          backgroundColor: SashTheme.primary.withOpacity(0.2),
          child: const Icon(Icons.person_outline, color: SashTheme.primary),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text("₹${_totalBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat("Overview", Icons.trending_up, SashTheme.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'));
  }

  Widget _buildAccountStrip() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return _buildAccountItem(
            account['name'], 
            "₹${account['balance'].toStringAsFixed(0)}", 
            account['type'] == 'Wallet' ? Icons.payments : Icons.account_balance
          );
        },
      ),
    );
  }

  Widget _buildAccountItem(String name, String balance, IconData icon) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SashTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: SashTheme.primary),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          Text(balance, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text("🔥", style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("5 Day Streak!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Keep logging to maintain your habit.", style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return const Center(child: Text("No transactions yet", style: TextStyle(color: Colors.white24)));
    }
    return Column(
      children: _recentTransactions.map((t) => _buildTransactionItem(
        t['category_name'], 
        "${t['type'] == 'Credit' ? '+' : '-'}₹${t['amount']}", 
        t['date'].toString().split('T')[0], 
        Icons.circle, // Placeholder for icon
        t['type'] == 'Credit' ? SashTheme.accent : SashTheme.error
      )).toList(),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, IconData icon, Color amountColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SashTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: SashTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: SashTheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.white38)),
            ],
          ),
          const Spacer(),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: amountColor)),
        ],
      ),
    );
  }
}
