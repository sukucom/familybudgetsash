import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _familyController = TextEditingController(text: "Sash Household");
  final TextEditingController _userNameController = TextEditingController(text: "Primary User");
  final TextEditingController _balanceController = TextEditingController(text: "0");

  @override
  void dispose() {
    _pageController.dispose();
    _familyController.dispose();
    _userNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final db = DatabaseHelper.instance;
    
    // 1. Update Family Name
    await db.updateFamilyName(_familyController.text);
    
    // 2. Add Primary Member (assuming first member is ID 1)
    final members = await db.getMembers();
    if (members.isNotEmpty) {
      // Update existing default member
      // Note: We'd need an updateMember method in DB, for now let's just use what's there or insert
    }

    // 3. Update Initial Balance
    final accounts = await db.getAccounts();
    if (accounts.isNotEmpty) {
      final double balance = double.tryParse(_balanceController.text) ?? 0;
      final int accountId = accounts.first['id'];
      final database = await db.database;
      await database.update('accounts', {'balance': balance}, where: 'id = ?', whereArgs: [accountId]);
    }

    // 4. Set onboarding complete flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildWelcomeStep(),
              _buildInputStep(
                title: "Your Household",
                subtitle: "Give your family budget a name.",
                controller: _familyController,
                hint: "e.g. The Smiths",
                icon: Icons.home_rounded,
              ),
              _buildInputStep(
                title: "Your Identity",
                subtitle: "How should we address you?",
                controller: _userNameController,
                hint: "e.g. Alex",
                icon: Icons.person_rounded,
              ),
              _buildInputStep(
                title: "Initial Funds",
                subtitle: "What's your current cash in hand?",
                controller: _balanceController,
                hint: "0.00",
                icon: Icons.account_balance_wallet_rounded,
                isNumeric: true,
              ),
            ],
          ),
          _buildNavigationOverlay(),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/app_icon.png', height: 120),
          ),
          const SizedBox(height: 40),
          const Text(
            "Welcome to SASH Budget",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 16),
          const Text(
            "Track. Save. Grow Together.\nLet's get your household set up in seconds.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputStep({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 64, color: SashTheme.primary),
          const SizedBox(height: 32),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white10),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SashTheme.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOverlay() {
    return Positioned(
      bottom: 60,
      left: 40,
      right: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(4, (index) => _buildPageIndicator(index)),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: SashTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_currentPage == 3 ? "GET STARTED" : "NEXT"),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? SashTheme.primary : Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
