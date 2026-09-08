import 'package:adaptive_ui_lab/core/app/app_restart_controller.dart';
import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:adaptive_ui_lab/data/models/app_settings.dart';
import 'package:adaptive_ui_lab/state/settings_bloc.dart';
import 'package:adaptive_ui_lab/ui/shared/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'mock_repository.dart';

double appliedScale(WidgetTester tester) {
  final context = tester.element(find.text(AppStrings.fontScale).first);
  return MediaQuery.textScalerOf(context).scale(100) / 100;
}

double pendingScale(WidgetTester tester) {
  final context = tester.element(find.text(AppStrings.fontScale).first);
  return BlocProvider.of<SettingsBloc>(context).state.settings.pendingFontScale;
}

void main() {
  setUpAll(registerRepositoryFallbacks);

  setUp(() {
    platformController.reset();
    appRestartController.reset();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
    appRestartController.reset();
  });

  testWidgets(
    'Material: slider UI shriftini oʻzgartirmaydi, restart qoʻllaydi',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pumpApp(tester, tabIndex: 2);

      expect(appliedScale(tester), AppSettings.defaultFontScale);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text(AppStrings.fontScalePending), findsNothing);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, AppStrings.fontScaleDefault),
            )
            .onPressed,
        isNull,
      );

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pumpAndSettle();

      final pending = pendingScale(tester);
      expect(pending, greaterThan(AppSettings.defaultFontScale));
      expect(appliedScale(tester), AppSettings.defaultFontScale);
      expect(find.text(AppStrings.fontScalePending), findsOneWidget);
      expect(find.text(AppStrings.refreshHint), findsOneWidget);

      final before = appRestartController.tick.value;
      await tester.tap(
        find.widgetWithText(SnackBarAction, AppStrings.refreshAction),
      );
      await tester.pumpAndSettle();

      expect(appRestartController.tick.value, before + 1);
      expect(appliedScale(tester), pending);
      expect(find.text(AppStrings.fontScalePending), findsNothing);

      await tester.tap(
        find.widgetWithText(TextButton, AppStrings.fontScaleDefault),
      );
      await tester.pumpAndSettle();

      expect(appliedScale(tester), pending);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text(AppStrings.fontScalePending), findsOneWidget);

      final inlineRefresh = find.descendant(
        of: find.byType(ListView),
        matching: find.widgetWithText(TextButton, AppStrings.refreshAction),
      );
      expect(inlineRefresh, findsOneWidget);

      await tester.tap(inlineRefresh);
      await tester.pumpAndSettle();

      expect(appliedScale(tester), AppSettings.defaultFontScale);
      expect(find.text(AppStrings.fontScalePending), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'Cupertino: slider UI shriftini oʻzgartirmaydi, restart qoʻllaydi',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pumpApp(tester, tabIndex: 2);

      expect(appliedScale(tester), AppSettings.defaultFontScale);
      expect(find.text(AppStrings.fontScalePending), findsNothing);
      expect(
        tester
            .widget<CupertinoButton>(
              find.widgetWithText(CupertinoButton, AppStrings.fontScaleDefault),
            )
            .onPressed,
        isNull,
      );

      await tester.drag(find.byType(CupertinoSlider), const Offset(120, 0));
      await tester.pumpAndSettle();

      final pending = pendingScale(tester);
      expect(pending, greaterThan(AppSettings.defaultFontScale));
      expect(appliedScale(tester), AppSettings.defaultFontScale);
      expect(find.text(AppStrings.fontScalePending), findsOneWidget);
      expect(find.text(AppStrings.refreshHint), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.refreshHint), findsNothing);

      final before = appRestartController.tick.value;
      await tester.tap(
        find.widgetWithText(CupertinoListTile, AppStrings.refreshAction),
      );
      await tester.pumpAndSettle();

      expect(appRestartController.tick.value, before + 1);
      expect(appliedScale(tester), pending);
      expect(find.text(AppStrings.fontScalePending), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    },
  );
}
