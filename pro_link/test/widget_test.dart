import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_link/screens/admin/admin_dashboard.dart';
import 'package:pro_link/screens/admin/upload_schedule_screen.dart';
import 'package:pro_link/screens/intern/intern_dashboard.dart';
import 'package:pro_link/screens/mentor/mentor_dashboard.dart';
import 'package:pro_link/screens/shared/search_screen.dart';

Widget _testApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  testWidgets(
      'admin dashboard exposes profile, search, notifications, and settings',
      (tester) async {
    await tester.pumpWidget(_testApp(const AdminDashboard()));
    await tester.pump();

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets(
      'mentor dashboard exposes profile, search, notifications, and settings',
      (tester) async {
    await tester.pumpWidget(_testApp(const MentorDashboard()));
    await tester.pump();

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets(
      'intern dashboard exposes search, notifications, profile, and settings',
      (tester) async {
    await tester.pumpWidget(_testApp(const InternDashboard()));
    await tester.pump();

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('upload schedule screen shows recent schedules', (tester) async {
    await tester.pumpWidget(_testApp(const UploadScheduleScreen()));
    await tester.pump();

    expect(find.text('Recent Schedules'), findsOneWidget);
  });

  testWidgets('search result rows expose an action affordance', (tester) async {
    await tester.pumpWidget(_testApp(const SearchScreen()));

    await tester.enterText(
      find.byType(TextField),
      'policy',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );

    expect(find.text('Corporate Internship Policy'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsWidgets);
  });
}
