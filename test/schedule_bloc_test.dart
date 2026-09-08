import 'package:adaptive_ui_lab/data/fake_repository.dart';
import 'package:adaptive_ui_lab/data/models/schedule_item.dart';
import 'package:adaptive_ui_lab/state/schedule_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  late MockRepository repository;

  setUp(() => repository = buildMockRepository());

  group('ScheduleBloc', () {
    blocTest<ScheduleBloc, ScheduleState>(
      'ikkala doiradagi maʼlumot bir marta yuklanadi',
      build: () => ScheduleBloc(repository),
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        isA<ScheduleState>().having(
          (s) => s.status,
          'status',
          ScheduleStatus.loading,
        ),
        isA<ScheduleState>()
            .having((s) => s.status, 'status', ScheduleStatus.success)
            .having((s) => s.todayItems, 'todayItems', testToday)
            .having((s) => s.weekItems, 'weekItems', testWeek),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'doira almashganda items oʻzgaradi, qayta yuklanmaydi',
      build: () => ScheduleBloc(repository),
      act: (bloc) async {
        bloc.add(const ScheduleRequested());
        await bloc.stream.firstWhere((s) => s.status == ScheduleStatus.success);
        bloc.add(const ScheduleScopeChanged(ScheduleScope.week));
      },
      skip: 2,
      expect: () => [
        isA<ScheduleState>()
            .having((s) => s.scope, 'scope', ScheduleScope.week)
            .having((s) => s.items, 'items', testWeek),
      ],
      verify: (_) {
        verify(() => repository.fetchSchedule(ScheduleScope.today)).called(1);
        verify(() => repository.fetchSchedule(ScheduleScope.week)).called(1);
      },
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'xatolik failure holatiga olib keladi',
      setUp: () {
        when(
          () => repository.fetchSchedule(any()),
        ).thenThrow(const RepositoryFailure('Kun tartibi yoʻq'));
      },
      build: () => ScheduleBloc(repository),
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        isA<ScheduleState>().having(
          (s) => s.status,
          'status',
          ScheduleStatus.loading,
        ),
        isA<ScheduleState>()
            .having((s) => s.status, 'status', ScheduleStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Kun tartibi yoʻq'),
      ],
    );

    test('boʻlimlar guruh boʻyicha ajratiladi', () async {
      final bloc = ScheduleBloc(repository);
      bloc.add(const ScheduleRequested());
      await bloc.stream.firstWhere((s) => s.status == ScheduleStatus.success);
      final sections = bloc.state.sectionsFor(ScheduleScope.today);
      expect(sections.keys, [ScheduleGroup.morning, ScheduleGroup.midday]);
      expect(sections[ScheduleGroup.morning], hasLength(1));
      await bloc.close();
    });
  });
}
