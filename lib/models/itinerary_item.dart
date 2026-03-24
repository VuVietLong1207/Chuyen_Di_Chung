import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ItineraryItem {
  final String id;
  String title;
  String? description;
  DateTime date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String location;

  ItineraryItem({
    String? id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.location,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'startTime': startTime != null
        ? '${startTime!.hour}:${startTime!.minute}'
        : null,
    'endTime': endTime != null
        ? '${endTime!.hour}:${endTime!.minute}'
        : null,
    'location': location,
  };

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    TimeOfDay? start;
    if (json['startTime'] != null) {
      final parts = json['startTime'].split(':');
      start = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    TimeOfDay? end;
    if (json['endTime'] != null) {
      final parts = json['endTime'].split(':');
      end = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return ItineraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: start,
      endTime: end,
      location: json['location'],
    );
  }
}