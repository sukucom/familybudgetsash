import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final db = DatabaseHelper.instance;
      final jsonStr = await db.exportFullDatabase();

      if (jsonStr == '{}' || jsonStr.isEmpty) {
        _showSnackBar("No data to export", SashTheme.error);
        return;
      }

      // Save to persistent storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = "family_budget_backup_${DateTime.now().millisecondsSinceEpoch}.json";
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsString(jsonStr);

      _showSnackBar("Backup saved locally: $fileName", SashTheme.accent);

      // Share
      await Share.shareXFiles([XFile(path)], text: 'My Family Budget SASH Backup');
    } catch (e) {
      _showSnackBar("Export failed: $e", SashTheme.error);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      final db = DatabaseHelper.instance;
      await db.importFullDatabase(jsonString);

      _showSnackBar("Successfully restored backup!", SashTheme.accent);
    } catch (e) {
      _showSnackBar("Import failed: $e", SashTheme.error);
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Data Management", style: TextStyle(fontFamily: 'Outfit')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildActionCard(
              "Export Backup", 
              "Save your entire database as a JSON backup file to your device or cloud storage.",
              Icons.upload_file_outlined,
              _isExporting,
              _exportData,
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              "Import Backup", 
              "Restore your database from a JSON backup. Warning: This will overwrite your current data.",
              Icons.download_for_offline_outlined,
              _isImporting,
              _importData,
            ),
            const Spacer(),
            const Text(
              "Note: A backup contains all your accounts, categories, and transactions. Restoring a backup completely replaces your current records.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, bool isLoading, VoidCallback onTap) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SashTheme.primary, size: 32),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: SashTheme.primary.withOpacity(0.1),
                foregroundColor: SashTheme.primary,
                side: const BorderSide(color: SashTheme.primary),
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(title),
            ),
          ),
        ],
      ),
    );
  }
}
