import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import 'expense_screen.dart';
import 'itinerary_screen.dart';
import 'documents_screen.dart';
import 'checklist_screen.dart';
import 'map_screen.dart';
import 'package:intl/intl.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;
  TripDetailScreen({required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        final trip = tripProvider.getTripById(tripId);
        
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Chi tiết Chuyến đi'),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chuyến đi không tồn tại'),
                ],
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 7,
          child: Scaffold(
            appBar: AppBar(
              title: Text(trip.name),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              bottom: TabBar(
                labelColor: Color(0xFFFFA500),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFFFFA500),
                tabs: [
                  Tab(text: 'Tổng quan'),
                  Tab(text: 'Bản đồ'),
                  Tab(text: 'Thành viên'),
                  Tab(text: 'Lịch trình'),
                  Tab(text: 'Chia tiền'),
                  Tab(text: 'Tài liệu'),
                  Tab(text: 'Checklist'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildOverview(context, trip, tripProvider),
                MapScreen(trip: trip),
                _buildMembers(context, trip, tripProvider),
                ItineraryScreen(trip: trip),
                ExpenseScreen(trip: trip),
                DocumentsScreen(trip: trip),
                ChecklistScreen(trip: trip),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverview(BuildContext context, Trip trip, TripProvider tripProvider) {
    final spent = trip.totalSpent;
    final percent = trip.spentPercentage;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Info Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Destination Title
                    Text(
                      trip.destination,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    // Date Range
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(trip.startDate)} - ${DateFormat('dd/MM/yyyy').format(trip.endDate)}',
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    SizedBox(height: 24),
                    // Budget Section Title
                    Text(
                      'Tổng quan ngân sách',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        fontSize: 14,
                        color: Colors.black87
                      ),
                    ),
                    SizedBox(height: 16),
                    // Spent Amount Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã chi tiêu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(
                          '${NumberFormat.currency(symbol: 'VND', locale: 'vi_VN', decimalDigits: 0).format(spent)} / ${NumberFormat.currency(symbol: 'VND', locale: 'vi_VN', decimalDigits: 0).format(trip.budget)}',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            color: Colors.black87
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (percent / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent > 100 ? Color(0xFFE74C3C) : Color(0xFF27AE60)
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Percentage Text
                    Text(
                      '${percent.toStringAsFixed(2)}% ngân sách đã được sử dụng',
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // End Trip Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Kết thúc chuyến đi'),
                      content: Text('Bạn có chắc muốn kết thúc chuyến đi này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Kết thúc'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA500),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Kết thúc chuyến đi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: Colors.white,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Delete Trip Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Xóa chuyến đi'),
                      content: Text('Hành động này không thể hoàn tác.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            tripProvider.deleteTrip(trip.id);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Xóa', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Xóa chuyến đi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMembers(BuildContext context, Trip trip, TripProvider tripProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Mã mời'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Mã chia sẻ:', style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          SelectableText(
                            trip.id.substring(0, 8),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFA500),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.person_add, size: 18),
                label: Text('Sao chép mã'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA500),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (trip.members.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có thành viên nào',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: trip.members.length,
                itemBuilder: (ctx, i) => Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFFFA500),
                      child: Text(
                        trip.members[i][0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    title: Text(
                      trip.members[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
