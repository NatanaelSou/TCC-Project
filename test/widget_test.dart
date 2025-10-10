// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app/main.dart';
import 'package:app/user_state.dart';
import 'package:app/utils/filter_manager.dart';
import 'package:app/providers/theme_provider.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Set a larger screen size to avoid overflow issues
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserState()),
          ChangeNotifierProvider(create: (_) => FilterManager()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: MyApp(),
      ),
    );

    // Wait for any async operations
    await tester.pumpAndSettle();

    // Verify that the app built successfully (no crash)
    expect(find.byType(MaterialApp), findsOneWidget);

    // Reset screen size
    tester.view.resetPhysicalSize();
  });
}
