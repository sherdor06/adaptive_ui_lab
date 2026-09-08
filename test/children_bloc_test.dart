import 'package:adaptive_ui_lab/data/fake_repository.dart';
import 'package:adaptive_ui_lab/state/children_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';
import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  late MockRepository repository;

  setUp(() => repository = buildMockRepository());

  group('ChildrenBloc', () {
    test('boshlangʻich holat boʻsh', () {
      final bloc = ChildrenBloc(repository);
      expect(bloc.state.status, ChildrenStatus.initial);
      expect(bloc.state.children, isEmpty);
      expect(bloc.state.filter, ChildrenFilter.all);
      bloc.close();
    });

    blocTest<ChildrenBloc, ChildrenState>(
      'ChildrenRequested roʻyxatni yuklaydi',
      build: () => ChildrenBloc(repository),
      act: (bloc) => bloc.add(const ChildrenRequested()),
      expect: () => [
        isA<ChildrenState>().having(
          (s) => s.status,
          'status',
          ChildrenStatus.loading,
        ),
        isA<ChildrenState>()
            .having((s) => s.status, 'status', ChildrenStatus.success)
            .having((s) => s.children, 'children', testChildren),
      ],
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'xato holatida failure va xabar qaytadi',
      setUp: () {
        when(
          repository.fetchChildren,
        ).thenThrow(const RepositoryFailure('Tarmoq xatosi'));
      },
      build: () => ChildrenBloc(repository),
      act: (bloc) => bloc.add(const ChildrenRequested()),
      expect: () => [
        isA<ChildrenState>().having(
          (s) => s.status,
          'status',
          ChildrenStatus.loading,
        ),
        isA<ChildrenState>()
            .having((s) => s.status, 'status', ChildrenStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Tarmoq xatosi'),
      ],
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'qidiruv faqat mos bolalarni qoldiradi',
      build: () => ChildrenBloc(repository),
      act: (bloc) async {
        bloc.add(const ChildrenRequested());
        await bloc.stream.firstWhere((s) => s.status == ChildrenStatus.success);
        bloc.add(const ChildrenQueryChanged('bek'));
      },
      skip: 2,
      expect: () => [
        isA<ChildrenState>().having((s) => s.query, 'query', 'bek').having(
          (s) => s.visibleChildren,
          'visibleChildren',
          [bekzod],
        ),
      ],
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'qidiruv bogʻcha nomi boʻyicha ham ishlaydi',
      build: () => ChildrenBloc(repository),
      act: (bloc) async {
        bloc.add(const ChildrenRequested());
        await bloc.stream.firstWhere((s) => s.status == ChildrenStatus.success);
        bloc.add(const ChildrenQueryChanged('Bolajon'));
      },
      skip: 2,
      expect: () => [
        isA<ChildrenState>().having(
          (s) => s.visibleChildren,
          'visibleChildren',
          [dilnoza],
        ),
      ],
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'filtr faqat bugun kelganlarni qoldiradi',
      build: () => ChildrenBloc(repository),
      act: (bloc) async {
        bloc.add(const ChildrenRequested());
        await bloc.stream.firstWhere((s) => s.status == ChildrenStatus.success);
        bloc.add(const ChildrenFilterChanged(ChildrenFilter.arrivedToday));
      },
      skip: 2,
      expect: () => [
        isA<ChildrenState>()
            .having((s) => s.filter, 'filter', ChildrenFilter.arrivedToday)
            .having((s) => s.visibleChildren, 'visibleChildren', [
              amina,
              dilnoza,
            ]),
      ],
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'refresh repozitoriyani qayta chaqiradi',
      build: () => ChildrenBloc(repository),
      act: (bloc) async {
        bloc.add(const ChildrenRequested());
        await bloc.stream.firstWhere((s) => s.status == ChildrenStatus.success);
        bloc.add(const ChildrenRefreshed());
      },
      verify: (_) => verify(repository.fetchChildren).called(2),
    );

    blocTest<ChildrenBloc, ChildrenState>(
      'oʻchirish va bekor qilish roʻyxatni tiklaydi',
      build: () => ChildrenBloc(repository),
      act: (bloc) async {
        bloc.add(const ChildrenRequested());
        await bloc.stream.firstWhere((s) => s.status == ChildrenStatus.success);
        bloc.add(ChildDeleted(bekzod));
        await bloc.stream.firstWhere((s) => s.children.length == 2);
        bloc.add(const ChildDeleteUndone());
      },
      skip: 2,
      expect: () => [
        isA<ChildrenState>()
            .having((s) => s.children, 'children', [amina, dilnoza])
            .having((s) => s.canUndo, 'canUndo', true),
        isA<ChildrenState>()
            .having((s) => s.children, 'children', testChildren)
            .having((s) => s.canUndo, 'canUndo', false),
      ],
      verify: (_) {
        verify(() => repository.deleteChild('c2')).called(1);
        verify(() => repository.restoreChild(bekzod, 1)).called(1);
      },
    );
  });
}
