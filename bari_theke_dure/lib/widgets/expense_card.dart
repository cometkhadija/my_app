import 'package:bari_theke_dure/utils/constants.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat = categories.firstWhere((c) => c['name'] == expense.category);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cat['color'],
          child: Icon(cat['icon'], color: Colors.white),
        ),
        title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${expense.date.day}/${expense.date.month}/${expense.date.year}"),
        trailing: Text("৳ ${expense.amount.toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }
}