import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tripsync.db');
    if (File(path).existsSync()) {
      await File(path).delete();
    }
    _database = null;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tripsync.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Trips (
            TripId TEXT PRIMARY KEY,
            Name TEXT NOT NULL,
            Destination TEXT NOT NULL,
            Latitude REAL,
            Longitude REAL,
            StartDate TEXT NOT NULL,
            EndDate TEXT NOT NULL,
            Budget REAL NOT NULL,
            Currency TEXT NOT NULL,
            Members TEXT NOT NULL,
            Expenses TEXT NOT NULL,
            Itinerary TEXT NOT NULL,
            Documents TEXT NOT NULL,
            Checklist TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE Trips ADD COLUMN Latitude REAL DEFAULT 0');
            await db.execute('ALTER TABLE Trips ADD COLUMN Longitude REAL DEFAULT 0');
          } catch (e) {
            print('Error upgrading database: $e');
          }
        }
      },
    );
  }

  Future<List<Trip>> getTrips() async {
    try {
      final db = await database;
      final maps = await db.query('Trips');
      return maps.map((e) {
        try {
          final json = {
            'id': e['TripId'],
            'name': e['Name'],
            'destination': e['Destination'],
            'latitude': (e['Latitude'] as num?)?.toDouble(),
            'longitude': (e['Longitude'] as num?)?.toDouble(),
            'startDate': e['StartDate'],
            'endDate': e['EndDate'],
            'budget': e['Budget'],
            'currency': e['Currency'],
            'members': jsonDecode(e['Members'] as String),
            'expenses': jsonDecode(e['Expenses'] as String),
            'itinerary': jsonDecode(e['Itinerary'] as String),
            'documents': jsonDecode(e['Documents'] as String),
            'checklist': jsonDecode(e['Checklist'] as String),
          };
          return Trip.fromJson(json);
        } catch (e) {
          print('Error converting trip: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching trips: $e. Deleting and reinitializing database.');
      await deleteDatabase();
      _database = null;
      return [];
    }
  }

  Future<void> insertTrip(Trip trip) async {
    final db = await database;
    await db.insert(
      'Trips',
      {
        'TripId': trip.id,
        'Latitude': trip.latitude,
        'Longitude': trip.longitude,
        'Name': trip.name,
        'Destination': trip.destination,
        'StartDate': trip.startDate.toIso8601String(),
        'EndDate': trip.endDate.toIso8601String(),
        'Budget': trip.budget,
        'Currency': trip.currency,
        'Members': jsonEncode(trip.members),
        'Expenses': jsonEncode(trip.expenses.map((e) => e.toJson()).toList()),
        'Itinerary': jsonEncode(trip.itinerary.map((e) => e.toJson()).toList()),
        'Documents': jsonEncode(trip.documents.map((e) => e.toJson()).toList()),
        'Checklist': jsonEncode(trip.checklist.map((e) => e.toJson()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await database;
    await db.update(
      'Trips',
      {
        'Name': trip.name,
        'Destination': trip.destination,
        'Latitude': trip.latitude,
        'Longitude': trip.longitude,
        'StartDate': trip.startDate.toIso8601String(),
        'EndDate': trip.endDate.toIso8601String(),
        'Budget': trip.budget,
        'Currency': trip.currency,
        'Members': jsonEncode(trip.members),
        'Expenses': jsonEncode(trip.expenses.map((e) => e.toJson()).toList()),
        'Itinerary': jsonEncode(trip.itinerary.map((e) => e.toJson()).toList()),
        'Documents': jsonEncode(trip.documents.map((e) => e.toJson()).toList()),
        'Checklist': jsonEncode(trip.checklist.map((e) => e.toJson()).toList()),
      },
      where: 'TripId = ?',
      whereArgs: [trip.id],
    );
  }

  Future<void> deleteTrip(String tripId) async {
    final db = await database;
    await db.delete('Trips', where: 'TripId = ?', whereArgs: [tripId]);
  }
}
