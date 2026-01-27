import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakin_app/data/hive_database.dart';
import 'package:sakin_app/services/location_service.dart';
import 'package:sakin_app/main.dart';

void main() {
  testWidgets('SakinApp smoke test', (WidgetTester tester) async {
    // Create mock services for testing
    final hiveDb = HiveDatabase();
    final locationService = LocationService();

    // Build our app and trigger a frame
    await tester.pumpWidget(SakinApp(
      hiveDb: hiveDb,
      locationService: locationService,
    ));

    // Verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
