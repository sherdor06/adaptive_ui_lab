import 'dart:math' as math;

import 'package:adaptive_ui_lab/core/platform/platform_controller.dart';
import 'package:adaptive_ui_lab/data/models/schedule_item.dart';
import 'package:adaptive_ui_lab/state/children_bloc.dart';
import 'package:adaptive_ui_lab/state/schedule_bloc.dart';
import 'package:adaptive_ui_lab/ui/material/m_children_page.dart';
import 'package:adaptive_ui_lab/ui/material/m_schedule_page.dart';
import 'package:adaptive_ui_lab/ui/material/m_settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'app_harness.dart';
import 'fixtures.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  late MockRepository repository;

  setUp(() => repository = buildMockRepository());

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    platformController.reset();
  });

  test('visibleChildren bir marta hisoblanadi va keshlanadi', () {
    final state = ChildrenState(
      status: ChildrenStatus.success,
      children: testChildren,
      query: 'dil',
    );

    expect(identical(state.visibleChildren, state.visibleChildren), isTrue);
    expect(state.visibleChildren, [dilnoza]);
  });

  test('filtrsiz holatda nusxa olinmaydi', () {
    final state = ChildrenState(
      status: ChildrenStatus.success,
      children: testChildren,
    );

    expect(identical(state.visibleChildren, testChildren), isTrue);
  });

  test('sectionsFor keshlanadi', () {
    final state = ScheduleState(
      status: ScheduleStatus.success,
      todayItems: testToday,
      weekItems: testWeek,
    );

    expect(
      identical(
        state.sectionsFor(ScheduleScope.today),
        state.sectionsFor(ScheduleScope.today),
      ),
      isTrue,
    );
    expect(state.sectionsFor(ScheduleScope.week).keys, [ScheduleGroup.monday]);
  });

  test('kun tartibi ikkala doirani parallel yuklaydi', () async {
    var active = 0;
    var maxActive = 0;
    when(() => repository.fetchSchedule(any())).thenAnswer((_) async {
      active++;
      maxActive = math.max(maxActive, active);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      active--;
      return testToday;
    });

    final bloc = ScheduleBloc(repository);
    bloc.add(const ScheduleRequested());
    await bloc.stream.firstWhere((s) => s.status == ScheduleStatus.success);
    await bloc.close();

    expect(maxActive, 2);
  });

  testWidgets('koʻrilmagan tablar qurilmaydi', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpApp(tester);

    expect(find.byType(MChildrenPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(MSchedulePage, skipOffstage: false), findsNothing);
    expect(find.byType(MSettingsPage, skipOffstage: false), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(MSettingsPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(MChildrenPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(MSchedulePage, skipOffstage: false), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('qidiruvda yozilganda AppBar qayta chizilmaydi', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpApp(tester);

    final appBarElement = tester.element(find.byType(SliverAppBar));
    final rebuilt = <Element>[];
    void onRebuild(Element element, bool builtOnce) => rebuilt.add(element);

    debugOnRebuildDirtyWidget = onRebuild;
    await tester.enterText(find.byType(SearchBar), 'dil');
    await tester.pumpAndSettle();
    debugOnRebuildDirtyWidget = null;

    expect(find.text('Dilnoza Rasulova'), findsOneWidget);
    expect(rebuilt, isNot(contains(appBarElement)));

    debugDefaultTargetPlatformOverride = null;
  });
}
