import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper.instance.getAccounts();
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  void _showAddAccountDialog() {
    String name = "";
    String type = "Bank";
    double balance = 0;

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
            const Text("Add New Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Account Name (e.g. HDFC Bank)"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              onChanged: (val) => type = val!,
              items: ["Bank", "Wallet", "Credit Card"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              decoration: const InputDecoration(labelText: "Account Type"),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => balance = double.tryParse(val) ?? 0,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Initial Balance"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await DatabaseHelper.instance.insertAccount({
                      'family_id': 1, // Default
                      'name': name,
                      'type': type,
                      'balance': balance,
                    });
                    Navigator.pop(context);
                    _loadAccounts();
                  }
                },
                child: const Text("Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditAccountDialog(Map<String, dynamic> account) {
    String name = account['name'];
    String type = account['type'];
    double balance = (account['balance'] as num).toDouble();

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
            const Text("Edit Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: name,
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Account Name (e.g. HDFC Bank)"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              onChanged: (val) => type = val!,
              items: ["Bank", "Wallet", "Credit Card"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              decoration: const InputDecoration(labelText: "Account Type"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: balance.toString(),
              onChanged: (val) => balance = double.tryParse(val) ?? 0,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Current Balance"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await DatabaseHelper.instance.updateAccount({
                      'id': account['id'],
                      'family_id': account['family_id'],
                      'name': name,
                      'type': type,
                      'balance': balance,
                    });
                    Navigator.pop(context);
                    _loadAccounts();
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Accounts", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      Text("Manage your money sources", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  IconButton(
                    onPressed: _showAddAccountDialog,
                    icon: const Icon(Icons.add_circle, color: SashTheme.primary, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ..._accounts.map((acc) => _buildAccountCard(acc)).toList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showEditAccountDialog(acc),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SashTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                acc['type'] == 'Wallet' ? Icons.payments : Icons.account_balance,
                color: SashTheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(acc['type'], style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5))),
                ],
              ),
            ),
            Text(
              "₹${(acc['balance'] as num).toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
