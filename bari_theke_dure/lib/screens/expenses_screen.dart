import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/daily_message_card.dart';
import '../widgets/category_dialog.dart';
import '../utils/constants.dart';
import 'package:uuid/uuid.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Expense> expenses = [];
  double monthlyBudget = 30000;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    expenses = await ExpenseService.getExpenses();
    monthlyBudget = await ExpenseService.getBudget();
    setState(() {});
  }

  List<Expense> getTodayExpenses() {
    final today = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return d == today;
    }).toList();
  }

  double getTodayTotal() {
    return getTodayExpenses().fold(0, (sum, e) => sum + e.amount);
  }

  double getPerDayBudget() {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    return monthlyBudget / daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    final todayTotal = getTodayTotal();
    final perDay = getPerDayBudget();

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 20),
            color: primaryColor,
            width: double.infinity,
            child: Text(
              "My Expenses",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: accentColor,
            tabs: [Tab(text: "Today"), Tab(text: "This Week"), Tab(text: "This Month")],
          ),

          // Pie Chart Area
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: getTodayExpenses().isEmpty
                ? Center(child: Text("আজ কোনো খরচ নেই", style: TextStyle(fontSize: 18)))
                : PieChart(
                    PieChartData(
                      sections: getTodayExpenses().map((e) {
                        final cat = categories.firstWhere((c) => c['name'] == e.category);
                        return PieChartSectionData(
                          value: e.amount,
                          color: cat['color'],
                          title: "${e.amount.toInt()}",
                          radius: 60,
                        );
                      }).toList(),
                    ),
                  ),
          ),

          // Budget | Month | Per Day
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _infoCard("Budget", "৳ ${monthlyBudget.toStringAsFixed(0)}", Colors.green)),
                Expanded(child: _infoCard("Month", DateFormat('MMMM yyyy').format(DateTime.now()), Colors.blue)),
                Expanded(child: _infoCard("Per Day", "৳ ${perDay.toStringAsFixed(0)}", Colors.orange)),
              ],
            ),
          ),

          dailyMessageCard(todayTotal, perDay),

          // Expense List
          Expanded(
            child: ListView.builder(
              itemCount: getTodayExpenses().length,
              itemBuilder: (ctx, i) {
                final exp = getTodayExpenses()[i];
                return ExpenseCard(
                  expense: exp,
                  onEdit: () {
                    // Edit logic (optional)
                  },
                  onDelete: () async {
                    await ExpenseService.deleteExpense(exp.id);
                    loadData();
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: Icon(Icons.add, size: 30),
        onPressed: () => showCategoryDialog(context, (cat, amount) async {
          final expense = Expense(
            id: Uuid().v4(),
            category: cat,
            amount: amount,
            date: DateTime.now(),
          );
          await ExpenseService.addExpense(expense);
          loadData();
        }),
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 14)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }
}