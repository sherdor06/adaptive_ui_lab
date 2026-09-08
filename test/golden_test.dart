import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
  });

  testWidgets('Material bolalar ekrani goldeni', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    platformController.reset();
    await pumpApp(tester, surface: kPhoneSurface);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/material_children.png'),
    );

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Cupertino bolalar ekrani goldeni', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    platformController.reset();
    await pumpApp(tester, surface: kPhoneSurface);

    await expectLater(
      find.byType(CupertinoApp),
      matchesGoldenFile('goldens/cupertino_children.png'),
    );

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Material sozlamalar ekrani goldeni', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    platformController.reset();
    await pumpApp(tester, surface: kPhoneSurface, tabIndex: 2);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/material_settings.png'),
    );

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Cupertino sozlamalar ekrani goldeni', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    platformController.reset();
    await pumpApp(tester, surface: kPhoneSurface, tabIndex: 2);

    await expectLater(
      find.byType(CupertinoApp),
      matchesGoldenFile('goldens/cupertino_settings.png'),
    );

    debugDefaultTargetPlatformOverride = null;
  });
}
