// lib/screens/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';
import '../utils/constants.dart';

class ChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  const ChartScreen({required this.expenses, super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> catMap = {};
    for (var e in expenses) {
      catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
    }
   final total = catMap.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: Text("Expense Chart"), backgroundColor: Color(0xFF1A237E)),
      body: catMap.isEmpty
          ? Center(child: Text("No data"))
          : Padding(
              padding: EdgeInsets.all(20),
              child: PieChart(
                PieChartData(
                  sections: catMap.entries.map((e) {
                    final cat = categories.firstWhere((c) => c['name'] == e.key);
                    final percent = (e.value / total) * 100;
                    return PieChartSectionData(
                      color: cat['color'],
                      value: e.value,
                      title: "${percent.toStringAsFixed(1)}%",
                      radius: 100,
                      titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}