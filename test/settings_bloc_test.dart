import 'package:adaptive_ui_lab/data/models/app_settings.dart';
import 'package:adaptive_ui_lab/state/settings_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_repository.dart';

void main() {
  setUpAll(registerRepositoryFallbacks);

  late MockRepository repository;

  setUp(() => repository = buildMockRepository());

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'sozlamalar yuklanadi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc.add(const SettingsRequested()),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.status,
          'status',
          SettingsStatus.loading,
        ),
        isA<SettingsState>().having(
          (s) => s.status,
          'status',
          SettingsStatus.success,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'switch qiymati saqlanadi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc.add(const SettingsNotificationsToggled(false)),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.notifications,
          'notifications',
          false,
        ),
      ],
      verify: (_) => verify(() => repository.saveSettings(any())).called(1),
    );

    blocTest<SettingsBloc, SettingsState>(
      'slider faqat kutilayotgan qiymatni oʻzgartiradi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc.add(const SettingsFontScaleChanged(1.3)),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.pendingFontScale, 'pendingFontScale', 1.3)
            .having(
              (s) => s.settings.fontScale,
              'fontScale',
              AppSettings.defaultFontScale,
            )
            .having((s) => s.settings.hasPendingFontScale, 'hasPending', true),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'qayta ishga tushirilgach kutilayotgan qiymat qoʻllanadi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc
        ..add(const SettingsFontScaleChanged(1.3))
        ..add(const SettingsFontScaleApplied()),
      skip: 1,
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.fontScale, 'fontScale', 1.3)
            .having((s) => s.settings.pendingFontScale, 'pendingFontScale', 1.3)
            .having((s) => s.settings.hasPendingFontScale, 'hasPending', false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'standart tugmasi shriftni boshlangʻich qiymatga qaytaradi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc
        ..add(const SettingsFontScaleChanged(1.4))
        ..add(const SettingsFontScaleReset()),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.pendingFontScale,
          'pendingFontScale',
          1.4,
        ),
        isA<SettingsState>().having(
          (s) => s.settings.pendingFontScale,
          'pendingFontScale',
          AppSettings.defaultFontScale,
        ),
      ],
      verify: (_) => verify(() => repository.saveSettings(any())).called(2),
    );

    blocTest<SettingsBloc, SettingsState>(
      'til, sana va matn qiymatlari saqlanadi',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc
        ..add(const SettingsLanguageChanged(AppLanguage.english))
        ..add(SettingsBirthDateChanged(DateTime(1990, 1, 2)))
        ..add(const SettingsParentNameChanged('Nodira')),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.language,
          'language',
          AppLanguage.english,
        ),
        isA<SettingsState>().having(
          (s) => s.settings.birthDate,
          'birthDate',
          DateTime(1990, 1, 2),
        ),
        isA<SettingsState>().having(
          (s) => s.settings.parentName,
          'parentName',
          'Nodira',
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'tozalash boshlangʻich qiymatlarni qaytaradi',
      build: () => SettingsBloc(repository),
      act: (bloc) async {
        bloc.add(const SettingsParentNameChanged('Nodira'));
        await bloc.stream.first;
        bloc.add(const SettingsCleared());
      },
      skip: 1,
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.status,
          'status',
          SettingsStatus.loading,
        ),
        isA<SettingsState>().having(
          (s) => s.settings,
          'settings',
          AppSettings.defaults(),
        ),
      ],
    );
  });
}
