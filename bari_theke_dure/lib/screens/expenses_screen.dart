// lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/category_dialog.dart';
import 'chart_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> expenses = [];
  double monthlyBudget = 30000.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    expenses = await ExpenseService.getExpenses();
    monthlyBudget = await ExpenseService.getBudget();
    setState(() {});
  }

  double getTodayTotal() {
    final today = DateTime.now();
    return expenses
        .where((e) => isSameDay(e.date, today))
        .fold(0, (sum, e) => sum + e.amount);
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double getPerDayBudget() {
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    return monthlyBudget / daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    final perDay = getPerDayBudget();
    final todayTotal = getTodayTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text("My Expenses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Navy shade navbar
          Container(
            color: const Color(0xFF283593),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navButton("Today", 0),
                _navButton("This Week", 1),
                _navButton("This Month", 2),
              ],
            ),
          ),

          // Pie Chart Button
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChartScreen(expenses: expenses))),
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 60, color: Color(0xFF8B0000)),
                    SizedBox(height: 10),
                    Text("Tap to view detailed chart", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),

          // Budget | Month | Per Day
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _info("Budget", "৳ ${monthlyBudget.toInt()}", true),
                _info("Month", DateFormat('MMMM yyyy').format(DateTime.now()), false),
                _info("Per Day", "৳ ${perDay.toInt()}", false),
              ],
            ),
          ),

          // Message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: todayTotal > perDay ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: todayTotal > perDay ? Colors.red : Colors.green),
              ),
              child: Text(
                todayTotal > perDay
                    ? "আজ বাজেট ছাড়িয়ে গেছে! অতিরিক্ত ৳${(todayTotal - perDay).toInt()}"
                    : "আজ বাকি আছে ৳${(perDay - todayTotal).toInt()}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: todayTotal > perDay ? Colors.red[800] : Colors.green[800]),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Expense List
          Expanded(
            child: expenses.isEmpty
                ? Center(child: Text("কোনো খরচ নেই", style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (ctx, i) {
                      final exp = expenses[i];
                      final cat = categories.firstWhere((c) => c['name'] == exp.category);
                      return Dismissible(
                        key: Key(exp.id),
                        background: Container(color: Colors.red, child: Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.delete, color: Colors.white)))),
                        secondaryBackground: Container(color: Colors.blue, child: Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.edit, color: Colors.white)))),
                        onDismissed: (dir) async {
                          await ExpenseService.deleteExpense(exp.id);
                          loadData();
                        },
                        confirmDismiss: (dir) async {
                          if (dir == DismissDirection.endToStart) {
                            _editExpense(exp);
                            return false;
                          }
                          return true;
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: cat['color'], child: Icon(cat['icon'], color: Colors.white)),
                            title: Text(exp.category, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(exp.date)),
                            trailing: Text("৳ ${exp.amount.toInt()}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A237E),
        onPressed: () => showCategoryDialog(context, (cat, amount) async {
          await ExpenseService.addExpense(Expense(id: const Uuid().v4(), category: cat, amount: amount, date: DateTime.now()));
          loadData();
        }),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _navButton(String text, int index) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _info(String title, String value, bool editable) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
        if (editable) GestureDetector(onTap: _showBudgetDialog, child: Icon(Icons.edit, size: 18, color: Colors.grey)),
      ],
    );
  }

  void _showBudgetDialog() {
    final controller = TextEditingController(text: monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Monthly Budget"),
        content: TextField(controller: controller, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final budget = double.tryParse(controller.text) ?? 30000;
              await ExpenseService.setBudget(budget);
              setState(() => monthlyBudget = budget);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editExpense(Expense exp) {
    // Edit coming soon or implement full edit
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Edit: ${exp.category} - ৳${exp.amount}")));
  }
}