// lib/services/expense_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _user = FirebaseAuth.instance.currentUser;

  static CollectionReference get _collection => _firestore
      .collection('users')
      .doc(_user?.uid)
      .collection('expenses');

  static Future<List<Expense>> getExpenses() async {
    if (_user == null) return [];
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
  final data = doc.data() as Map<String, dynamic>;
  final expense = Expense.fromJson(data);
  return expense.copyWith(id: doc.id); // এটাই সঠিক উপায়
}).toList();
  }

  static Future<void> addExpense(Expense expense) async {
    if (_user == null) return;
    await _collection.add(expense.toJson());
  }

  static Future<void> updateExpense(Expense expense) async {
    if (_user == null) return;
    await _collection.doc(expense.id).update(expense.toJson());
  }

  static Future<void> deleteExpense(String id) async {
    if (_user == null) return;
    await _collection.doc(id).delete();
  }

  static Future<double> getBudget() async {
    if (_user == null) return 30000;
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    return doc['monthlyBudget']?.toDouble() ?? 30000;
  }

  static Future<void> setBudget(double budget) async {
    if (_user == null) return;
    await _firestore.collection('users').doc(_user!.uid).set({'monthlyBudget': budget}, SetOptions(merge: true));
  }
}