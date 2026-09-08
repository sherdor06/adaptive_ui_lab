import 'package:adaptive_ui_lab/data/fake_repository.dart';
import 'package:adaptive_ui_lab/data/models/app_settings.dart';
import 'package:adaptive_ui_lab/data/models/child.dart';
import 'package:adaptive_ui_lab/data/models/schedule_item.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';

class MockRepository extends Mock implements FakeRepository {}

void registerRepositoryFallbacks() {
  registerFallbackValue(ScheduleScope.today);
  registerFallbackValue(AppSettings.defaults());
  registerFallbackValue(amina);
}

MockRepository buildMockRepository() {
  final repository = MockRepository();
  when(repository.fetchChildren).thenAnswer((_) async => testChildren);
  when(
    () => repository.fetchSchedule(ScheduleScope.today),
  ).thenAnswer((_) async => testToday);
  when(
    () => repository.fetchSchedule(ScheduleScope.week),
  ).thenAnswer((_) async => testWeek);
  when(repository.loadSettings).thenAnswer((_) async => AppSettings.defaults());
  when(
    repository.clearSettings,
  ).thenAnswer((_) async => AppSettings.defaults());
  when(() => repository.saveSettings(any())).thenAnswer(
    (invocation) async => invocation.positionalArguments.first as AppSettings,
  );
  when(() => repository.deleteChild(any())).thenAnswer((_) async {});
  when(() => repository.restoreChild(any(), any())).thenAnswer((_) async {});
  return repository;
}

Child get firstChild => amina;
