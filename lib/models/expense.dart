import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  String title;
  double amount;
  String category;
  DateTime date;
  String paidBy;
  List<String> splitAmong;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paidBy,
    required this.splitAmong,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'paidBy': paidBy,
    'splitAmong': splitAmong,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    category: json['category'],
    date: DateTime.parse(json['date']),
    paidBy: json['paidBy'],
    splitAmong: List<String>.from(json['splitAmong']),
  );
}