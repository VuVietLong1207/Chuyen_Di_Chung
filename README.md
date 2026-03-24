HEAD
# btl_nhom

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Database Integration

This project now uses local SQLite as the source of truth for trips in `lib/db/database_helper.dart`.

- The app persists `Trips` with fields:
  - `TripId`, `Name`, `Destination`, `StartDate`, `EndDate`, `Budget`, `Currency`, `Members`, `Expenses`, `Itinerary`, `Documents`, `Checklist`.
- The legacy `SharedPreferences` payload (`trips`) is migrated on first start and saved in SQLite.
- The schema in `tripsync_schema.sql` is the design reference (User/Trips/Itinerary/Expenses/Documents/Checklist), and local DB uses a compatible normalized form.

### Run

1. `flutter pub get`
2. `flutter run`
3. Tạo chuyến đi và kiểm tra dữ liệu lưu trong SQLite.

# Chuyen_Di_Chung
9aa0e26dfb2ff3261efb5f0ffd55bdeff1422490
