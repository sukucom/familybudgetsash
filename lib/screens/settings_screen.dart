import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'categories_screen.dart';
import 'family_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Settings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              const Text("Customize your SASH experience", style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              
              _buildSettingsSection("Preferences"),
              _buildSettingsItem(
                "Manage Categories", 
                "Add or edit expense & income types", 
                Icons.category_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())),
              ),
              _buildSettingsItem(
                "Family Setup", 
                "Manage members and permissions", 
                Icons.people_outline,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FamilySetupScreen())),
              ),
              
              const SizedBox(height: 24),
              _buildSettingsSection("Data & Security"),
              _buildSettingsItem("Export Data", "Download your transactions as CSV", Icons.download_outlined),
              _buildSettingsItem("Privacy Policy", "How we handle your data", Icons.security_outlined),
              
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Text("Family Budget SASH", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
                    const Text("Version 1.0.0", style: TextStyle(color: Colors.white10, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title, style: TextStyle(color: SashTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white10),
            ],
          ),
        ),
      ),
    );
  }
}
