import 'package:flutter/material.dart';

Widget dailyMessageCard(double todaySpent, double perDayBudget) {
  final remaining = perDayBudget - todaySpent;
  final over = todaySpent > perDayBudget;

  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: over ? Colors.red[50] : Colors.green[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: over ? Colors.red : Colors.green),
    ),
    child: Text(
      over
          ? "আজ বাজেট ছাড়িয়ে গেছে! অতিরিক্ত: ৳${(todaySpent - perDayBudget).toStringAsFixed(0)}"
          : remaining < perDayBudget * 0.2
              ? "সাবধান! বাজেট প্রায় শেষ: আর মাত্র ৳${remaining.toStringAsFixed(0)} বাকি"
              : "আজকের খরচ: ৳${todaySpent.toStringAsFixed(0)} | বাকি: ৳${remaining.toStringAsFixed(0)}",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: over ? Colors.red[800] : Colors.green[800],
      ),
      textAlign: TextAlign.center,
    ),
  );
}