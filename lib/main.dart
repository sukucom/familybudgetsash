import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database & Automation
  await DatabaseHelper.instance.database;
  DatabaseHelper.instance.processRecurringTransactions().catchError((e) {
    debugPrint("Error processing recurring transactions: $e");
  });
  
  // Check Onboarding Status
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);
  final String? savedTheme = prefs.getString('theme_mode');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialTheme: savedTheme),
      child: FamilyBudgetSASH(showOnboarding: showOnboarding),
    ),
  );
}

class FamilyBudgetSASH extends StatelessWidget {
  final bool showOnboarding;
  const FamilyBudgetSASH({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'SASH Budget',
      debugShowCheckedModeBanner: false,
      theme: SashTheme.lightTheme,
      darkTheme: SashTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: showOnboarding ? const OnboardingScreen() : const MainNavigation(),
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text('Exit App', style: TextStyle(fontFamily: 'Outfit', color: Theme.of(context).colorScheme.onSurface)),
              content: Text('Are you sure you want to exit?', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit', style: TextStyle(color: SashTheme.error)),
                ),
              ],
            );
          },
        );
        if (shouldPop ?? false) {
          if (Platform.isAndroid) {
            exit(0);
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: SashTheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
            setState(() {
              _refreshCount++;
            });
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
      ),
    );
  }
}
