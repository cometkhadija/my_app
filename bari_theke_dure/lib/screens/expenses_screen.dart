// lib/screens/expenses_screen.dart

import 'package:bari_theke_dure/widgets/daily_message_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/category_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Expense> allExpenses = [];
  double monthlyBudget = 30000.0;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => selectedTab = _tabController.index);
      }
    });
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    allExpenses = await ExpenseService.getExpenses();
    monthlyBudget = await ExpenseService.getBudget();
    setState(() {});
  }

  List<Expense> getFilteredExpenses() {
    final now = DateTime.now();
    return allExpenses.where((e) {
      if (selectedTab == 0) {
        // Today
        return isSameDay(e.date, now);
      } else if (selectedTab == 1) {
        // This Week
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(weekStart.add(const Duration(days: 7)));
      } else {
        // This Month
        return e.date.month == now.month && e.date.year == now.year;
      }
    }).toList();
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double getTotal() =>
      getFilteredExpenses().fold(0, (sum, e) => sum + e.amount);

  double getPerDayBudget() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return monthlyBudget / daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredExpenses();
    final total = getTotal();
    final perDay = getPerDayBudget();

    // Category wise amount map
    final Map<String, double> catMap = {};
    for (var e in filtered) {
      catMap.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Deep Navy
        foregroundColor: Colors.white,
        title: const Text("My Expenses",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "This Week"),
            Tab(text: "This Month"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Pie Chart + Percentage List
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            child: filtered.isEmpty
                ? const Center(
                    child: Text("কোনো খরচ নেই",
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  )
                : Row(
                    children: [
                      // Left: Pie Chart
                      Expanded(
                        flex: 5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: catMap.entries.map((entry) {
                              final cat = categories.firstWhere(
                                  (c) => c['name'] == entry.key);
                              final percentage = (entry.value / total) * 100;
                              return PieChartSectionData(
                                color: cat['color'],
                                value: entry.value,
                                title: "${percentage.toStringAsFixed(0)}%",
                                radius: 70,
                                titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      // Right: Percentage List
                      Expanded(
                        flex: 4,
                        child: ListView.builder(
                          itemCount: catMap.length,
                          itemBuilder: (ctx, i) {
                            final entry = catMap.entries.elementAt(i);
                            final cat = categories.firstWhere(
                                (c) => c['name'] == entry.key);
                            final percentage = (entry.value / total) * 100;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                      width: 14,
                                      height: 14,
                                      color: cat['color']),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(entry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600))),
                                  Text("${percentage.toStringAsFixed(1)}%",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // Budget, Month, Per Day (নিচে একসাথে)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoItem("Budget", "৳ ${monthlyBudget.toStringAsFixed(0)}", true),
                _infoItem("Month", DateFormat('MMMM yyyy').format(DateTime.now()), false),
                _infoItem("Per Day", "৳ ${perDay.toStringAsFixed(0)}", false),
              ],
            ),
          ),

          // Daily Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: dailyMessageCard(
                total, selectedTab == 0 ? perDay : perDay * 7),
          ),

          // Expense List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text("এখনো কোনো খরচ যোগ করা হয়নি",
                        style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final exp = filtered[i];
                      final cat = categories
                          .firstWhere((c) => c['name'] == exp.category);
                      return Dismissible(
                        key: Key(exp.id),
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white)),
                        secondaryBackground: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.edit, color: Colors.white)),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await ExpenseService.deleteExpense(exp.id);
                            loadData();
                            return true;
                          } else {
                            _showEditDialog(exp);
                            return false;
                          }
                        },
                        child: Card(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: cat['color'],
                                child: Icon(cat['icon'], color: Colors.white)),
                            title: Text(exp.category,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                DateFormat('dd MMM, hh:mm a').format(exp.date)),
                            trailing: Text("৳ ${exp.amount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Bottom Center Add Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF1A237E),
          onPressed: () => showCategoryDialog(context, (cat, amount) async {
            await ExpenseService.addExpense(Expense(
              id: const Uuid().v4(),
              category: cat,
              amount: amount,
              date: DateTime.now(),
            ));
            loadData();
          }),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Expense", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _infoItem(String title, String value, bool editable) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A237E))),
        if (editable)
          GestureDetector(
            onTap: _showBudgetDialog,
            child: const Icon(Icons.edit, size: 18, color: Colors.grey),
          ),
      ],
    );
  }

  void _showBudgetDialog() {
    final controller =
        TextEditingController(text: monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Monthly Budget"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "যেমন: 45000"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text) ?? 30000;
              ExpenseService.setBudget(newBudget);
              setState(() => monthlyBudget = newBudget);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Expense exp) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit feature coming soon!")),
    );
  }
}