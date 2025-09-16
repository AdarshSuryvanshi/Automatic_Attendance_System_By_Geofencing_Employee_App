import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'employee_stats_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://geofenceat-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  runApp(MyApp(rtdb: rtdb));
}

class MyApp extends StatelessWidget {
  final FirebaseDatabase rtdb;
  const MyApp({super.key, required this.rtdb});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Geofence App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AuthPage(rtdb: rtdb),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthPage extends StatefulWidget {
  final FirebaseDatabase rtdb;
  const AuthPage({super.key, required this.rtdb});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();

  String message = '';
  bool loading = false;

  // Geofence data
  String? geofenceName;
  String? locationAddress;
  double? lat;
  double? lon;
  double? radiusMeters;
  String? employeeName;
  String? phone;

  // Attendance status
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  String? checkInTime;
  String? checkOutTime;

  // Distance formula (Haversine)
  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi/180
    final c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  // Calculate total hours between two DateTime strings
  double _calculateTotalHours(String checkInStr, String checkOutStr) {
    try {
      final checkIn = DateTime.parse(checkInStr);
      final checkOut = DateTime.parse(checkOutStr);
      final difference = checkOut.difference(checkIn);
      return difference.inMinutes / 60.0; // Convert minutes to hours
    } catch (e) {
      return 0.0;
    }
  }

  // Check current attendance status
  Future<void> _checkAttendanceStatus() async {
    if (phone == null || phone!.isEmpty) return;

    final now = DateTime.now().toUtc();
    final dateKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final ref = widget.rtdb.ref('attendance/$dateKey/$phone');

    final snapshot = await ref.get();

    setState(() {
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        final status = data?['status']?.toString() ?? '';
        hasCheckedIn = data?['check_in'] != null && status != 'absent';
        hasCheckedOut = data?['check_out'] != null;
        checkInTime = data?['check_in']?.toString();
        checkOutTime = data?['check_out']?.toString();
      } else {
        hasCheckedIn = false;
        hasCheckedOut = false;
        checkInTime = null;
        checkOutTime = null;
      }
    });
  }

  // Verify credentials & load geofence
  Future<void> _verifyAndFetchGeofence() async {
    setState(() {
      loading = true;
      message = '';
      geofenceName = null;
      locationAddress = null;
      lat = null;
      lon = null;
      radiusMeters = null;
      employeeName = null;
    });

    phone = _phoneCtl.text.trim();
    final passwordInput = _passwordCtl.text.trim();

    if (phone!.isEmpty || passwordInput.isEmpty) {
      setState(() {
        loading = false;
        message = 'Enter phone number and password';
      });
      return;
    }

    try {
      // 1) Get employee document from Firestore
      final empDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(phone)
          .get();

      if (!empDoc.exists) {
        setState(() {
          loading = false;
          message = 'Employee not found in database';
        });
        return;
      }

      final emp = empDoc.data()!;
      final storedPassword = (emp['password'] ?? '').toString();

      // 2) Verify password
      if (storedPassword != passwordInput) {
        setState(() {
          loading = false;
          message = 'Invalid password. Access denied.';
        });
        return;
      }

      employeeName = (emp['name'] ?? '').toString();
      final geofenceId = (emp['geofence_id'] ?? '').toString();

      if (geofenceId.isEmpty) {
        setState(() {
          loading = false;
          message = 'No geofence assigned to this employee';
        });
        return;
      }

      // 3) Fetch geofence document from Firestore
      final geoDoc = await FirebaseFirestore.instance
          .collection('geofences')
          .doc(geofenceId)
          .get();

      if (!geoDoc.exists) {
        setState(() {
          loading = false;
          message = 'Assigned geofence not found';
        });
        return;
      }

      final g = geoDoc.data()!;
      final gp = g['geopoint'] as GeoPoint?;

      if (gp == null) {
        setState(() {
          loading = false;
          message = 'Geofence coordinates not configured';
        });
        return;
      }

      lat = gp.latitude;
      lon = gp.longitude;
      geofenceName = (g['location_name'] ?? '').toString();
      locationAddress = (g['location_add'] ?? '').toString();
      final r = g['radius'];
      radiusMeters = (r is num) ? r.toDouble() : double.tryParse(r.toString()) ?? 10.0;

      // Check today's attendance status
      await _checkAttendanceStatus();

      setState(() {
        loading = false;
        message = '✅ Authentication successful. Geofence loaded for $employeeName.';
      });

    } catch (e) {
      setState(() {
        loading = false;
        message = 'Error: ${e.toString()}';
      });
    }
  }

  // Check-In logic
  Future<void> _checkIn() async {
    if (lat == null || lon == null || radiusMeters == null) {
      setState(() => message = 'Please verify credentials and load geofence first');
      return;
    }

    if (hasCheckedIn && !hasCheckedOut) {
      setState(() => message = 'You have already checked in today. Use check-out to end your shift.');
      return;
    }

    if (hasCheckedIn && hasCheckedOut) {
      setState(() => message = 'You have completed today\'s attendance (checked in and out).');
      return;
    }

    setState(() {
      loading = true;
      message = 'Getting your location...';
    });

    try {
      // Request location permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
        if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
          setState(() {
            loading = false;
            message = 'Location permission is required for attendance tracking';
          });
          return;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distance from geofence center
      final dist = _distanceMeters(lat!, lon!, position.latitude, position.longitude);
      final inside = dist <= radiusMeters!;

      // Current timestamp
      final now = DateTime.now().toUtc();
      final dateKey =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final ref = widget.rtdb.ref('attendance/$dateKey/$phone');

      if (inside) {
        // Employee is inside geofence - allow check-in
        await ref.set({
          'check_in': now.toIso8601String(),
          'check_out': null,
          'total_hours': 0.0,
          'status': 'present',
          'name': employeeName ?? '',
          'geofence_name': geofenceName ?? '',
          'distance_meters': dist.round(),
        });

        await _checkAttendanceStatus(); // Refresh status

        setState(() {
          loading = false;
          message = '✅ CHECK-IN SUCCESSFUL!\nDistance: ${dist.toStringAsFixed(1)}m from center\nTime: ${now.toLocal().toString().substring(0, 19)}';
        });
      } else {
        setState(() {
          loading = false;
          message = '❌ CHECK-IN FAILED!\nYou are ${dist.toStringAsFixed(1)}m away from the geofence.\nRequired: Within ${radiusMeters!.toStringAsFixed(0)}m of $geofenceName';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        message = 'Error getting location: ${e.toString()}';
      });
    }
  }

  // Check-Out logic
  Future<void> _checkOut() async {
    if (lat == null || lon == null || radiusMeters == null) {
      setState(() => message = 'Please verify credentials and load geofence first');
      return;
    }

    if (!hasCheckedIn) {
      setState(() => message = 'You must check-in first before checking out');
      return;
    }

    if (hasCheckedOut) {
      setState(() => message = 'You have already checked out today');
      return;
    }

    setState(() {
      loading = true;
      message = 'Getting your location for check-out...';
    });

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distance from geofence center
      final dist = _distanceMeters(lat!, lon!, position.latitude, position.longitude);
      final inside = dist <= radiusMeters!;

      // Current timestamp
      final now = DateTime.now().toUtc();
      final dateKey =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final ref = widget.rtdb.ref('attendance/$dateKey/$phone');

      if (inside) {
        // Calculate total hours worked
        final totalHours = _calculateTotalHours(checkInTime!, now.toIso8601String());

        // Update the attendance record
        await ref.update({
          'check_out': now.toIso8601String(),
          'total_hours': totalHours,
          'status': 'completed',
        });

        await _checkAttendanceStatus(); // Refresh status

        setState(() {
          loading = false;
          message = '✅ CHECK-OUT SUCCESSFUL!\nTotal Hours Worked: ${totalHours.toStringAsFixed(2)} hours\nTime: ${now.toLocal().toString().substring(0, 19)}';
        });
      } else {
        setState(() {
          loading = false;
          message = '❌ CHECK-OUT FAILED!\nYou are ${dist.toStringAsFixed(1)}m away from the geofence.\nRequired: Within ${radiusMeters!.toStringAsFixed(0)}m of $geofenceName';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        message = 'Error getting location: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Login Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Employee Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (+91...)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: loading ? null : _verifyAndFetchGeofence,
                      child: loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Verify & Load Geofence'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Geofence Information
            if (lat != null && lon != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📍 Assigned Geofence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Name: ${geofenceName ?? 'Unknown'}'),
                      Text('Address: ${locationAddress ?? 'Not specified'}'),
                      Text('Coordinates: ${lat!.toStringAsFixed(6)}, ${lon!.toStringAsFixed(6)}'),
                      Text('Radius: ${radiusMeters!.toStringAsFixed(0)} meters'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Attendance Status
              Card(
                color: hasCheckedIn && hasCheckedOut
                    ? Colors.green.shade50
                    : hasCheckedIn
                    ? Colors.orange.shade50
                    : Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 Today\'s Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (hasCheckedIn) ...[
                        Text('✅ Checked In: ${checkInTime != null ? DateTime.parse(checkInTime!).toLocal().toString().substring(11, 19) : 'N/A'}'),
                        if (hasCheckedOut)
                          Text('✅ Checked Out: ${checkOutTime != null ? DateTime.parse(checkOutTime!).toLocal().toString().substring(11, 19) : 'N/A'}')
                        else
                          const Text('⏳ Not checked out yet'),
                      ] else
                        const Text('❌ Not checked in today'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (loading || (hasCheckedIn && !hasCheckedOut) || (hasCheckedIn && hasCheckedOut)) ? null : _checkIn,
                      icon: const Icon(Icons.login),
                      label: const Text('CHECK IN'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (loading || !hasCheckedIn || hasCheckedOut) ? null : _checkOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('CHECK OUT'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Message Display
            if (message.isNotEmpty)
              Card(
                color: message.contains('✅')
                    ? Colors.green.shade50
                    : message.contains('❌')
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: message.contains('✅')
                          ? Colors.green.shade800
                          : message.contains('❌')
                          ? Colors.red.shade800
                          : Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Statistics Button
            FilledButton.icon(
              onPressed: phone == null || phone!.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeStatsPage(
                      phone: phone!,
                      rtdb: widget.rtdb,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('📊 View Attendance Statistics'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}