import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:adaptive_ui_lab/core/platform/ui_platform.dart';
import 'package:adaptive_ui_lab/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_repository.dart';

const Size kTallSurface = Size(420, 1400);
const Size kPhoneSurface = Size(390, 844);

Future<MockRepository> pumpApp(
  WidgetTester tester, {
  UiStyleMode mode = UiStyleMode.system,
  int tabIndex = 0,
  Size surface = kTallSurface,
}) async {
  tester.view
    ..physicalSize = surface
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repository = buildMockRepository();
  platformController
    ..setMode(mode)
    ..setTabIndex(tabIndex);
  await tester.pumpWidget(AdaptiveUiLab(repository: repository));
  await tester.pumpAndSettle();
  return repository;
}
