import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../providers/trip_provider.dart';
import 'package:intl/intl.dart';

class ItineraryScreen extends StatefulWidget {
  final Trip trip;
  ItineraryScreen({required this.trip});

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final provider = Provider.of<TripProvider>(context, listen: false);
    // Group by date
    Map<DateTime, List<ItineraryItem>> grouped = {};
    for (var item in trip.itinerary) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      grouped.putIfAbsent(date, () => []).add(item);
    }
    final dates = grouped.keys.toList()..sort();

    return Column(
      children: [
        // Date picker or date list
        if (dates.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Chưa có ngày nào'),
          )
        else
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (ctx, i) {
                final date = dates[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 80,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedDate == date ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(date), style: TextStyle(color: _selectedDate == date ? Colors.white : Colors.black)),
                        Text(DateFormat('dd').format(date), style: TextStyle(fontWeight: FontWeight.bold, color: _selectedDate == date ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        // Itinerary for selected date
        Expanded(
          child: _selectedDate == null
              ? Center(child: Text('Vui lòng chọn một ngày để xem lịch trình'))
              : ListView.builder(
                  itemCount: grouped[_selectedDate]?.length ?? 0,
                  itemBuilder: (ctx, i) {
                    final item = grouped[_selectedDate]![i];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text('${item.location} ${item.startTime != null ? item.startTime!.format(context) : ''}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    );
                  },
                ),
        ),
        // Add activity button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _showAddActivityDialog(context, trip, provider);
            },
            child: Text('Thêm hoạt động'),
          ),
        ),
      ],
    );
  }

  void _showAddActivityDialog(BuildContext context, Trip trip, TripProvider provider) {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm hoạt động'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Tiêu đề hoạt động')),
              TextField(controller: locationCtrl, decoration: InputDecoration(labelText: 'Địa điểm')),
              ListTile(
                title: Text('Ngày'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: trip.startDate,
                    lastDate: trip.endDate,
                  );
                  if (date != null) selectedDate = date;
                },
              ),
              ListTile(
                title: Text('Thời gian bắt đầu'),
                subtitle: Text(startTime != null ? startTime!.format(context) : 'Chưa chọn'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time != null) startTime = time;
                },
              ),
              ListTile(
                title: Text('Thời gian kết thúc'),
                subtitle: Text(endTime != null ? endTime!.format(context) : 'Chưa chọn'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time != null) endTime = time;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              final newItem = ItineraryItem(
                title: titleCtrl.text,
                date: selectedDate,
                location: locationCtrl.text,
                startTime: startTime,
                endTime: endTime,
              );
              trip.itinerary.add(newItem);
              provider.updateTrip(trip);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }
}