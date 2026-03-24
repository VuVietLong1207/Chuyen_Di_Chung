import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../providers/trip_provider.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  final Trip trip;
  ExpenseScreen({required this.trip});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Ăn uống';
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final provider = Provider.of<TripProvider>(context, listen: false);
    return Column(
      children: [
        // Summary
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng ngân sách', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${NumberFormat.currency(symbol: trip.currency).format(trip.budget)}'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Đã chi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('${NumberFormat.currency(symbol: trip.currency).format(trip.totalSpent)}'),
                  Text('Còn lại ${NumberFormat.currency(symbol: trip.currency).format(trip.remainingBudget)}'),
                ],
              ),
            ],
          ),
        ),
        // Add Expense Form
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Mô tả', hintText: 'Ví dụ: Ăn trưa, Taxi,...'),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Số tiền'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Ăn uống', 'Di chuyển', 'Lưu trú', 'Tham quan', 'Khác']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: InputDecoration(labelText: 'Danh mục'),
              ),
              SizedBox(height: 16),
              CustomButton(
                text: 'Thêm khoản chi',
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                    final expense = Expense(
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      category: _category,
                      date: _date,
                      paidBy: trip.members.isNotEmpty ? trip.members[0] : '', // current user
                      splitAmong: trip.members.isNotEmpty ? trip.members : [],
                    );
                    trip.expenses.add(expense);
                    provider.updateTrip(trip);
                    _titleController.clear();
                    _amountController.clear();
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
        // Expense List
        Expanded(
          child: ListView.builder(
            itemCount: trip.expenses.length,
            itemBuilder: (ctx, i) {
              final e = trip.expenses[i];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.category} - ${DateFormat('dd/MM/yyyy').format(e.date)}'),
                trailing: Text('${NumberFormat.currency(symbol: trip.currency).format(e.amount)}'),
              );
            },
          ),
        ),
      ],
    );
  }
}