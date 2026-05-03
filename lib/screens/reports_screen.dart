import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  final int refreshTrigger;
  const ReportsScreen({super.key, this.refreshTrigger = 0});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _categoryData = [];
  bool _isLoading = true;
  double _totalAmount = 0;
  
  String _selectedTimeframe = 'This Month';
  String _selectedType = 'Debit'; // Debit for Expense, Credit for Income

  final List<String> _timeframes = ['This Month', 'Last Month', 'This Year', 'All Time'];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  @override
  void didUpdateWidget(ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _loadReportData();
    }
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getCategorySpending(
      timeframe: _selectedTimeframe,
      type: _selectedType,
    );
    
    double total = 0;
    for (var item in data) {
      total += (item['total'] as num).toDouble();
    }

    setState(() {
      _categoryData = data;
      _totalAmount = total;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildReportContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Insights", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 20),
          _buildTimeframeFilter(),
          const SizedBox(height: 16),
          _buildTypeToggle(),
        ],
      ),
    );
  }

  Widget _buildTimeframeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeframes.map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTimeframe = tf);
              _loadReportData();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? SashTheme.primary : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tf, style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleBtn("Expenses", "Debit"),
          _buildToggleBtn("Income", "Credit"),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, String value) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = value);
          _loadReportData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (_categoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("📊", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text("No data for $_selectedTimeframe", style: const TextStyle(color: Colors.white24)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildChartSection(),
          const SizedBox(height: 40),
          _buildCategoryList(),
          const SizedBox(height: 32),
        ],
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
              Text(_selectedType == 'Debit' ? "Spent" : "Earned", style: const TextStyle(color: Colors.white60, fontSize: 14)),
              Text("₹${_totalAmount.toStringAsFixed(0)}", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        const SizedBox(height: 16),
        ..._categoryData.map((data) => _buildCategoryItem(
          data['name'],
          data['icon'],
          "₹${(data['total'] as num).toStringAsFixed(0)}",
          ((data['total'] as num) / _totalAmount * 100).toStringAsFixed(1) + "%"
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
