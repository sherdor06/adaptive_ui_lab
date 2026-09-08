import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:adaptive_ui_lab/core/platform/ui_platform.dart';
import 'package:adaptive_ui_lab/data/models/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    platformController.reset();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
  });

  testWidgets('Android uchun Material daraxti quriladi', (tester) async {
    await pumpApp(tester);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
    expect(find.byType(ListTile), findsWidgets);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    expect(find.byType(CupertinoApp), findsNothing);
    expect(find.byType(CupertinoPageScaffold), findsNothing);
    expect(find.byType(CupertinoTabBar), findsNothing);
    expect(find.byType(CupertinoListSection), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Sozlamalar tabida Material boshqaruvlari koʻrinadi', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(Radio<AppThemeMode>), findsNWidgets(3));
    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(SegmentedButton<UiStyleMode>), findsOneWidget);
    expect(find.byType(DropdownMenu<AppLanguage>), findsOneWidget);

    expect(find.byType(CupertinoSwitch), findsNothing);
    expect(find.byType(CupertinoSlider), findsNothing);
    expect(find.byType(CupertinoTextField), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Oʻchirish AlertDialog orqali tasdiqlanadi', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Amina Karimova'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Oʻchirish'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(CupertinoAlertDialog), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Bekor qilish'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Ulashish modal bottom sheet ochadi', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Amina Karimova'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Ulashish'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(CupertinoActionSheet), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });
}
