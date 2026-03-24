import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../db/database_helper.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _trips = [];

  List<Trip> get trips => _trips;
  List<Trip> get upcomingTrips =>
      _trips.where((t) => t.startDate.isAfter(DateTime.now())).toList();
  List<Trip> get ongoingTrips =>
      _trips.where((t) => t.startDate.isBefore(DateTime.now()) && t.endDate.isAfter(DateTime.now())).toList();
  List<Trip> get pastTrips =>
      _trips.where((t) => t.endDate.isBefore(DateTime.now())).toList();

  TripProvider() {
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String? tripsJson = prefs.getString('trips');
      if (tripsJson != null) {
        List<dynamic> decoded = jsonDecode(tripsJson);
        _trips = decoded.map((t) => Trip.fromJson(t)).toList();
      } else {
        _trips = [];
      }
    } else {
      _trips = await DatabaseHelper.instance.getTrips();
      if (_trips.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final String? tripsJson = prefs.getString('trips');
        if (tripsJson != null) {
          List<dynamic> decoded = jsonDecode(tripsJson);
          _trips = decoded.map((t) => Trip.fromJson(t)).toList();
          for (final trip in _trips) {
            await DatabaseHelper.instance.insertTrip(trip);
          }
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveTrips() async {
    final jsonValue = jsonEncode(_trips.map((t) => t.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trips', jsonValue);

    if (!kIsWeb) {
      final futures = _trips.map((trip) => DatabaseHelper.instance.insertTrip(trip));
      await Future.wait(futures);
    }
  }

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    if (kIsWeb) {
      await _saveTrips();
    } else {
      await DatabaseHelper.instance.insertTrip(trip);
      await _saveTrips();
    }
    notifyListeners();
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    final index = _trips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      _trips[index] = updatedTrip;
      if (kIsWeb) {
        await _saveTrips();
      } else {
        await DatabaseHelper.instance.updateTrip(updatedTrip);
        await _saveTrips();
      }
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    if (kIsWeb) {
      await _saveTrips();
    } else {
      await DatabaseHelper.instance.deleteTrip(tripId);
      await _saveTrips();
    }
    notifyListeners();
  }

  Trip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}