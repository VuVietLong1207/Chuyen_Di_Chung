import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/checklist_item.dart';
import '../providers/trip_provider.dart';

class ChecklistScreen extends StatefulWidget {
  final Trip trip;
  ChecklistScreen({required this.trip});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<String> _categories = ['Hành lý', 'Giấy tờ', 'Sức khỏe', 'Khác'];

  void _addChecklistItem() {
    final nameCtrl = TextEditingController();
    String selectedCategory = _categories.first;
    String? assignedTo;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm mục checklist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Tên món đồ'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCategory = v!,
                decoration: InputDecoration(labelText: 'Danh mục'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: assignedTo,
                hint: Text('Người phụ trách (tùy chọn)'),
                items: [
                  DropdownMenuItem(value: null, child: Text('Không phân công')),
                  ...widget.trip.members.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                ],
                onChanged: (v) => assignedTo = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newItem = ChecklistItem(
                  name: nameCtrl.text,
                  category: selectedCategory,
                  assignedTo: assignedTo,
                );
                widget.trip.checklist.add(newItem);
                Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _toggleCompletion(ChecklistItem item) {
    item.isCompleted = !item.isCompleted;
    Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
    setState(() {});
  }

  void _deleteItem(ChecklistItem item) {
    widget.trip.checklist.remove(item);
    Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.trip.checklist;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addChecklistItem,
            icon: Icon(Icons.add),
            label: Text('Thêm món đồ'),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checklist, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Chưa có món đồ nào trong danh sách', style: TextStyle(color: Colors.grey)),
                      Text('Hãy thêm đồ cần mang theo!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return CheckboxListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.category}${item.assignedTo != null ? ' - Phụ trách: ${item.assignedTo}' : ''}'),
                      value: item.isCompleted,
                      onChanged: (_) => _toggleCompletion(item),
                      secondary: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}