import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee/main.dart';  // adjust if your lib folder structure is different
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:employee/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase for tests
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  testWidgets('EmployeeCheckinPage builds without crashing', (WidgetTester tester) async {
    // Create a fake RTDB instance (pointing to emulator or real URL)
    final rtdb = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://geofenceat-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

    // Pump your widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(rtdb: rtdb),
      ),
    );

    // Verify that phone input is shown
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Verify & Load Geofence'), findsOneWidget);
  });
}
