import 'package:uuid/uuid.dart';
import 'expense.dart';
import 'itinerary_item.dart';
import 'document.dart';
import 'checklist_item.dart';

class Trip {
  final String id;
  String name;
  String destination;
  double? latitude;
  double? longitude;
  DateTime startDate;
  DateTime endDate;
  double budget;
  String currency;
  List<String> members;
  List<Expense> expenses;
  List<ItineraryItem> itinerary;
  List<Document> documents;
  List<ChecklistItem> checklist;

  Trip({
    String? id,
    required this.name,
    required this.destination,
    this.latitude,
    this.longitude,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.currency = 'VND',
    List<String>? members,
    List<Expense>? expenses,
    List<ItineraryItem>? itinerary,
    List<Document>? documents,
    List<ChecklistItem>? checklist,
  }) : id = id ?? Uuid().v4(),
       members = members ?? [],
       expenses = expenses ?? [],
       itinerary = itinerary ?? [],
       documents = documents ?? [],
       checklist = checklist ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'destination': destination,
    'latitude': latitude,
    'longitude': longitude,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'budget': budget,
    'currency': currency,
    'members': members,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'itinerary': itinerary.map((i) => i.toJson()).toList(),
    'documents': documents.map((d) => d.toJson()).toList(),
    'checklist': checklist.map((c) => c.toJson()).toList(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    name: json['name'],
    destination: json['destination'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    budget: json['budget'],
    currency: json['currency'],
    members: List<String>.from(json['members']),
    expenses: (json['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList(),
    itinerary: (json['itinerary'] as List)
        .map((i) => ItineraryItem.fromJson(i))
        .toList(),
    documents: (json['documents'] as List)
        .map((d) => Document.fromJson(d))
        .toList(),
    checklist: (json['checklist'] as List)
        .map((c) => ChecklistItem.fromJson(c))
        .toList(),
  );

  double get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remainingBudget => budget - totalSpent;
  double get spentPercentage => budget == 0 ? 0 : (totalSpent / budget) * 100;
}