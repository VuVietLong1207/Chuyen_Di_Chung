import 'package:uuid/uuid.dart';

class ChecklistItem {
  final String id;
  String name;
  String category;
  String? assignedTo;
  bool isCompleted;

  ChecklistItem({
    String? id,
    required this.name,
    required this.category,
    this.assignedTo,
    this.isCompleted = false,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'assignedTo': assignedTo,
    'isCompleted': isCompleted,
  };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    assignedTo: json['assignedTo'],
    isCompleted: json['isCompleted'],
  );
}