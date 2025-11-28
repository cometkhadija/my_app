import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static const String _key = 'expenses';
  static const String _budgetKey = 'monthly_budget';

  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    final List jsonList = json.decode(data);
    return jsonList.map((e) => Expense.fromJson(e)).toList();
  }

  static Future<void> addExpense(Expense expense) async {
    final expenses = await getExpenses();
    expenses.add(expense);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(expenses.map((e) => e.toJson()).toList()));
  }

  static Future<void> updateExpense(Expense updated) async {
    final expenses = await getExpenses();
    final index = expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) expenses[index] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(expenses.map((e) => e.toJson()).toList()));
  }

  static Future<void> deleteExpense(String id) async {
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(expenses.map((e) => e.toJson()).toList()));
  }

  static Future<void> setBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, budget);
  }

  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 30000;
  }
}