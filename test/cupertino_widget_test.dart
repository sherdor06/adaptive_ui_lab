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
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    platformController.reset();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
  });

  testWidgets('iOS uchun Cupertino daraxti quriladi', (tester) async {
    await pumpApp(tester);

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(CupertinoPageScaffold), findsWidgets);
    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(find.byType(CupertinoListSection), findsOneWidget);
    expect(find.byType(CupertinoListTile), findsWidgets);
    expect(
      find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
      findsOneWidget,
    );

    expect(find.byType(MaterialApp), findsNothing);
    expect(find.byType(Scaffold), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(Card), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Sozlamalar tabida Cupertino boshqaruvlari koʻrinadi', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(CupertinoIcons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byType(CupertinoCheckbox), findsOneWidget);
    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(find.byType(CupertinoRadio<AppThemeMode>), findsNWidgets(3));
    expect(
      find.byType(CupertinoSlidingSegmentedControl<UiStyleMode>),
      findsOneWidget,
    );
    expect(find.byType(CupertinoTextField), findsWidgets);
    expect(find.byType(CupertinoFormSection), findsOneWidget);

    expect(find.byType(Switch), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.byType(TextField), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Oʻchirish CupertinoAlertDialog orqali tasdiqlanadi', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Amina Karimova'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    await tester.tap(find.widgetWithText(CupertinoButton, 'Oʻchirish'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(
      find.widgetWithText(CupertinoDialogAction, 'Bekor qilish'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Ulashish CupertinoActionSheet ochadi', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Amina Karimova'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CupertinoButton, 'Ulashish'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });
}
