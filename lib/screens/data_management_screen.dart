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
      final transactions = await db.getAllTransactionsDetailed();

      if (transactions.isEmpty) {
        _showSnackBar("No data to export", SashTheme.error);
        return;
      }

      // Convert to CSV
      List<List<dynamic>> csvData = [
        ['Amount', 'Date', 'Type', 'Category', 'Account', 'Note'],
        ...transactions.map((tx) => [
          tx['amount'],
          tx['date'],
          tx['type'],
          tx['category'],
          tx['account'],
          tx['note'] ?? ''
        ])
      ];

      String csvString = csv.encode(csvData);

      // Save to persistent storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = "family_budget_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsString(csvString);

      _showSnackBar("Export saved locally: $fileName", SashTheme.accent);

      // Share
      await Share.shareXFiles([XFile(path)], text: 'My Family Budget SASH Export');
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
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      List<List<dynamic>> csvData = csv.decode(csvString);

      if (csvData.length <= 1) {
        _showSnackBar("Empty or invalid CSV file", SashTheme.error);
        return;
      }

      final db = DatabaseHelper.instance;
      final categories = await db.getCategories();
      final accounts = await db.getAccounts();

      List<Map<String, dynamic>> toImport = [];
      
      // Basic header matching and mapping
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length < 5) continue;

        // Try to find matching category and account by name
        final catName = row[3].toString();
        final accName = row[4].toString();

        final cat = categories.firstWhere((c) => c.name == catName, orElse: () => categories.first);
        final acc = accounts.firstWhere((a) => a['name'] == accName, orElse: () => accounts.first);

        toImport.add({
          'account_id': acc['id'],
          'member_id': 1, // Default
          'category_id': cat.id,
          'amount': double.tryParse(row[0].toString()) ?? 0,
          'date': row[1].toString(),
          'type': row[2].toString(),
          'note': row.length > 5 ? row[5].toString() : null,
        });
      }

      if (toImport.isNotEmpty) {
        await db.insertTransactionsBatch(toImport);
        _showSnackBar("Successfully imported ${toImport.length} transactions!", SashTheme.accent);
      }
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
              "Export Data", 
              "Save your transactions as a CSV file to your device or cloud storage.",
              Icons.upload_file_outlined,
              _isExporting,
              _exportData,
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              "Import Data", 
              "Import transactions from a CSV file. Make sure it follows the SASH format.",
              Icons.download_for_offline_outlined,
              _isImporting,
              _importData,
            ),
            const Spacer(),
            const Text(
              "Note: Importing data will add to your current records. Ensure your CSV follows the exported format for best results.",
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
