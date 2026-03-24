import 'package:uuid/uuid.dart';

class Document {
  final String id;
  String name;
  String url; // local path or network URL
  DateTime uploadedAt;

  Document({
    String? id,
    required this.name,
    required this.url,
    required this.uploadedAt,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    name: json['name'],
    url: json['url'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
  );
}