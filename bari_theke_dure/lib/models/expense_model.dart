class Expense {
  late final String id;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        category: json['category'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
      );

  Future<List<Expense>> copyWith({required String id}) {}
}