import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _categoryData = [];
  bool _isLoading = true;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final data = await DatabaseHelper.instance.getCategorySpending();
    double total = 0;
    for (var item in data) {
      total += (item['total'] as num).toDouble();
    }

    setState(() {
      _categoryData = data;
      _totalExpense = total;
      _isLoading = false;
    });
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
              const Text("Insights", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              const Text("Monthly Spending Breakdown", style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              _buildChartSection(),
              const SizedBox(height: 40),
              _buildCategoryList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 240,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              sections: _getSections(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Spent", style: TextStyle(color: Colors.white60, fontSize: 14)),
              Text("₹${_totalExpense.toStringAsFixed(0)}", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    if (_categoryData.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.white10,
          value: 100,
          title: '',
          radius: 12,
        )
      ];
    }

    final colors = [
      SashTheme.primary,
      SashTheme.accent,
      SashTheme.error,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
    ];

    return List.generate(_categoryData.length, (i) {
      final data = _categoryData[i];
      final double value = (data['total'] as num).toDouble();
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '',
        radius: 12,
      );
    });
  }

  Widget _buildCategoryList() {
    if (_categoryData.isEmpty) {
      return const Center(child: Text("No expenses yet this month.", style: TextStyle(color: Colors.white24)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        const SizedBox(height: 16),
        ..._categoryData.map((data) => _buildCategoryItem(
          data['name'],
          data['icon'],
          "₹${(data['total'] as num).toStringAsFixed(0)}",
          ((data['total'] as num) / _totalExpense * 100).toStringAsFixed(1) + "%"
        )).toList(),
      ],
    );
  }

  Widget _buildCategoryItem(String name, String icon, String amount, String percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SashTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(percentage, style: const TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
