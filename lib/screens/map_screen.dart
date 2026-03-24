import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:url_launcher/url_launcher.dart';
import '../models/trip.dart';

class MapScreen extends StatefulWidget {
  final Trip trip;

  const MapScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  late LatLng destination;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      LatLng location;
      
      // Nếu đã có tọa độ hợp lệ
      if (widget.trip.latitude != null && widget.trip.latitude != 0 && 
          widget.trip.longitude != null && widget.trip.longitude != 0) {
        location = LatLng(widget.trip.latitude!, widget.trip.longitude!);
      } else {
        // Nếu chưa có tọa độ, thử địa chỉ hóa từ tên điểm đến
        try {
          List<geocoding.Location> locations = 
              await geocoding.locationFromAddress(widget.trip.destination);
          
          if (locations.isNotEmpty) {
            final lat = locations[0].latitude ?? 21.0285;
            final lng = locations[0].longitude ?? 105.8542;
            location = LatLng(lat, lng);
          } else {
            // Mặc định Hà Nội nếu không tìm được
            location = LatLng(21.0285, 105.8542);
          }
        } catch (e) {
          // Mặc định Hà Nội nếu có lỗi
          location = LatLng(21.0285, 105.8542);
        }
      }

      setState(() {
        destination = location;
        markers.add(
          Marker(
            markerId: MarkerId(widget.trip.id),
            position: location,
            infoWindow: InfoWindow(
              title: widget.trip.destination,
              snippet: widget.trip.name,
            ),
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Lỗi tải bản đồ: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA500)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    // Kiểm tra platform - Google Maps chỉ hỗ trợ Android/iOS, không hỗ trợ web
    if (kIsWeb) {
      return _buildWebFallback();
    }

    return _buildGoogleMap();
  }

  Widget _buildGoogleMap() {
    return Stack(
      children: [
        SizedBox.expand(
          child: GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: destination,
                    zoom: 13,
                  ),
                ),
              );
            },
            initialCameraPosition: CameraPosition(
              target: destination,
              zoom: 13,
            ),
            markers: markers,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Điểm đến',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.trip.destination,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tọa độ: ${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebFallback() {
    final googleMapsUrl = 'https://www.google.com/maps/search/'
        '${Uri.encodeComponent(widget.trip.destination)}'
        '/@${destination.latitude},${destination.longitude},13z';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hiển thị placeholder bản đồ
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 60,
                  color: Color(0xFFFFA500),
                ),
                SizedBox(height: 16),
                Text(
                  '${widget.trip.destination}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhấn nút bên dưới để xem bản đồ chi tiết',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Điểm đến',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.trip.destination,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tọa độ: ${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mở link trên Google Maps
                        launchUrl(Uri.parse(googleMapsUrl));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA500),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Xem trên Google Maps',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
