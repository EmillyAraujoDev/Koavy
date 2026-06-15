// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_loginkoavy/main.dart';

void main() {
  testWidgets('KoavyApp smoke test', (WidgetTester tester) async {
    // Set a larger surface size to avoid overflows in the test environment.
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const KoavyApp());

    // Verify that the initial screen (InterfacePage) is shown by checking for its main text.
    expect(find.text('Monitore seu coração em tempo real'), findsOneWidget);

    // Verify that the "Cadastre-se" button is present.
    expect(find.text('Cadastre-se'), findsOneWidget);

    // Reset the size after the test.
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
