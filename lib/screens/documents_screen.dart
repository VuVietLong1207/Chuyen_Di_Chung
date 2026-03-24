import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/trip.dart';
import '../models/document.dart';
import '../providers/trip_provider.dart';

class DocumentsScreen extends StatefulWidget {
  final Trip trip;
  DocumentsScreen({required this.trip});

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addDocument() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final newDoc = Document(
        name: pickedFile.name,
        url: pickedFile.path,
        uploadedAt: DateTime.now(),
      );
      widget.trip.documents.add(newDoc);
      Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
      setState(() {});
    } else {
      // optionally allow entering a document name without picking a file
      _showAddDocumentDialog();
    }
  }

  void _showAddDocumentDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm tài liệu'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Tên tài liệu'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newDoc = Document(
                  name: nameController.text,
                  url: '',
                  uploadedAt: DateTime.now(),
                );
                widget.trip.documents.add(newDoc);
                Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.trip.documents;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addDocument,
            icon: Icon(Icons.add),
            label: Text('Thêm tài liệu'),
          ),
        ),
        Expanded(
          child: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Chưa có tài liệu nào', style: TextStyle(color: Colors.grey)),
                      Text('Tài liệu để lưu trữ và chia sẻ với nhóm', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc = docs[i];
                    return ListTile(
                      leading: Icon(Icons.insert_drive_file),
                      title: Text(doc.name),
                      subtitle: Text('Đã tải lên: ${doc.uploadedAt.toLocal()}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.trip.documents.removeAt(i);
                            Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
                          });
                        },
                      ),
                      onTap: () {
                        if (doc.url.isNotEmpty) {
                          // For a real app, you'd open the file or show preview
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mở tài liệu: ${doc.url}')));
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}