import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'categories_screen.dart';
import 'family_setup_screen.dart';
import 'data_management_screen.dart';
import 'recurring_transactions_screen.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

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
              Text("Customize your SASH experience", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              _buildSettingsSection("Preferences"),
              _buildSettingsItem(
                context,
                "Manage Categories", 
                "Add or edit expense & income types", 
                Icons.category_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())),
              ),
              _buildSettingsItem(
                context,
                "Family Setup", 
                "Manage members and permissions", 
                Icons.people_outline,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FamilySetupScreen())),
              ),
              _buildSettingsItem(
                context,
                "Manage Subscriptions", 
                "Set up recurring bills and incomes", 
                Icons.event_repeat_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecurringTransactionsScreen())),
              ),
              _buildSettingsItem(
                context,
                "Appearance", 
                "Light, Dark, or System Theme", 
                Icons.palette_outlined,
                onTap: () => _showThemeSelector(context),
              ),
              
              const SizedBox(height: 24),
              _buildSettingsSection("Data & Security"),
              _buildSettingsItem(
                context,
                "Export/Import Data", 
                "Backup or restore your transactions", 
                Icons.import_export_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataManagementScreen())),
              ),
              _buildSettingsItem(context, "Privacy Policy", "How we handle your data", Icons.security_outlined),
              
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text("Family Budget SASH", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), fontWeight: FontWeight.bold)),
                    Text("Version 1.0.0", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), fontSize: 12)),
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

  Widget _buildSettingsItem(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Theme", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text("System Default"),
              trailing: provider.themeMode == ThemeMode.system ? const Icon(Icons.check, color: SashTheme.primary) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text("Light Mode"),
              trailing: provider.themeMode == ThemeMode.light ? const Icon(Icons.check, color: SashTheme.primary) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              trailing: provider.themeMode == ThemeMode.dark ? const Icon(Icons.check, color: SashTheme.primary) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
