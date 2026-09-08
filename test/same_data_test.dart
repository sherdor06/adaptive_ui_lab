import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:adaptive_ui_lab/core/platform/ui_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'fixtures.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
  });

  testWidgets('bitta bloc holati ikkala daraxtda bir xil matn chizadi', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpApp(tester);
    expect(find.byType(MaterialApp), findsOneWidget);
    for (final child in testChildren) {
      expect(find.text(child.name), findsOneWidget);
    }

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    platformController.reset();
    await pumpApp(tester);
    expect(find.byType(CupertinoApp), findsOneWidget);
    for (final child in testChildren) {
      expect(find.text(child.name), findsOneWidget);
    }

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('majburiy rejim tizim platformasini bekor qiladi', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpApp(tester, mode: UiStyleMode.forceCupertino);

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsNothing);
    expect(find.text('Amina Karimova'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Cupertino sozlamalaridan Material rejimiga oʻtiladi', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pumpApp(tester, tabIndex: 2);

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);

    await tester.tap(find.text('Material'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CupertinoApp), findsNothing);
    expect(find.byType(Switch), findsOneWidget);
    expect(platformController.tabIndex.value, 2);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('rejim almashganda maʼlumot va tanlangan tab saqlanadi', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpApp(tester);

    await tester.enterText(find.byType(SearchBar), 'dil');
    await tester.pumpAndSettle();
    expect(find.text('Dilnoza Rasulova'), findsOneWidget);
    expect(find.text('Amina Karimova'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cupertino'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(platformController.tabIndex.value, 2);
    expect(find.byType(CupertinoSwitch), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.person_2));
    await tester.pumpAndSettle();
    expect(find.text('Dilnoza Rasulova'), findsOneWidget);
    expect(find.text('Amina Karimova'), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });
}
