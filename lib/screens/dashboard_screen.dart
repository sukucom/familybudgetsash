import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
          const Text("₹2,45,680.50", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat("+₹12,400", Icons.arrow_upward, SashTheme.accent),
              const SizedBox(width: 20),
              _buildStat("-₹8,210", Icons.arrow_downward, SashTheme.error),
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAccountItem("ICICI Bank", "₹1,32,450", Icons.account_balance),
          _buildAccountItem("HDFC Bank", "₹98,230", Icons.credit_card),
          _buildAccountItem("Cash", "₹15,000", Icons.payments),
        ],
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
    return Column(
      children: [
        _buildTransactionItem("Groceries", "-₹3,210", "Today, 2:30 PM", Icons.shopping_basket, SashTheme.error),
        _buildTransactionItem("Salary", "+₹85,000", "Yesterday", Icons.work, SashTheme.accent),
        _buildTransactionItem("Rent", "-₹25,000", "1 May", Icons.home, SashTheme.error),
      ],
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
