import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/settings_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database
  await DatabaseHelper.instance.database;
  
  runApp(const FamilyBudgetSASH());
}

class FamilyBudgetSASH extends StatelessWidget {
  const FamilyBudgetSASH({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SASH Budget',
      debugShowCheckedModeBanner: false,
      theme: SashTheme.lightTheme,
      darkTheme: SashTheme.darkTheme,
      themeMode: ThemeMode.dark, // Defaulting to Dark Mode for the premium look
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _refreshCount = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(refreshTrigger: _refreshCount),
      ReportsScreen(refreshTrigger: _refreshCount),
      const AccountsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: SashTheme.backgroundDark,
        selectedItemColor: SashTheme.primary,
        unselectedItemColor: Colors.white24,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Accounts"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          
          if (result == true) {
            // Trigger rebuild of the whole navigation and increment refresh count
            setState(() {
              _refreshCount++;
            });
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
