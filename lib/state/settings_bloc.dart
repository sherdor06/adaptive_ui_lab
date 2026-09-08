import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_repository.dart';
import '../data/models/app_settings.dart';

enum SettingsStatus { initial, loading, success }

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => const [];
}

final class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

final class SettingsNotificationsToggled extends SettingsEvent {
  const SettingsNotificationsToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

final class SettingsSoundToggled extends SettingsEvent {
  const SettingsSoundToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

final class SettingsFontScaleChanged extends SettingsEvent {
  const SettingsFontScaleChanged(this.value);

  final double value;

  @override
  List<Object?> get props => [value];
}

final class SettingsFontScaleReset extends SettingsEvent {
  const SettingsFontScaleReset();
}

final class SettingsFontScaleApplied extends SettingsEvent {
  const SettingsFontScaleApplied();
}

final class SettingsLanguageChanged extends SettingsEvent {
  const SettingsLanguageChanged(this.value);

  final AppLanguage value;

  @override
  List<Object?> get props => [value];
}

final class SettingsThemeModeChanged extends SettingsEvent {
  const SettingsThemeModeChanged(this.value);

  final AppThemeMode value;

  @override
  List<Object?> get props => [value];
}

final class SettingsBirthDateChanged extends SettingsEvent {
  const SettingsBirthDateChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

final class SettingsParentNameChanged extends SettingsEvent {
  const SettingsParentNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class SettingsCleared extends SettingsEvent {
  const SettingsCleared();
}

class SettingsState extends Equatable {
  SettingsState({this.status = SettingsStatus.initial, AppSettings? settings})
    : settings = settings ?? AppSettings.defaults();

  final SettingsStatus status;
  final AppSettings settings;

  factory SettingsState.initial() => SettingsState();

  SettingsState copyWith({SettingsStatus? status, AppSettings? settings}) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [status, settings];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._repository) : super(SettingsState.initial()) {
    on<SettingsRequested>(_onRequested);
    on<SettingsNotificationsToggled>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(notifications: event.value)),
    );
    on<SettingsSoundToggled>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(soundAlerts: event.value)),
    );
    on<SettingsFontScaleChanged>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(pendingFontScale: event.value)),
    );
    on<SettingsFontScaleReset>(
      (event, emit) => _update(
        emit,
        state.settings.copyWith(pendingFontScale: AppSettings.defaultFontScale),
      ),
    );
    on<SettingsFontScaleApplied>(
      (event, emit) => _update(
        emit,
        state.settings.copyWith(fontScale: state.settings.pendingFontScale),
      ),
    );
    on<SettingsLanguageChanged>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(language: event.value)),
    );
    on<SettingsThemeModeChanged>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(themeMode: event.value)),
    );
    on<SettingsBirthDateChanged>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(birthDate: event.value)),
    );
    on<SettingsParentNameChanged>(
      (event, emit) =>
          _update(emit, state.settings.copyWith(parentName: event.value)),
    );
    on<SettingsCleared>(_onCleared);
  }

  final FakeRepository _repository;

  Future<void> _update(
    Emitter<SettingsState> emit,
    AppSettings settings,
  ) async {
    emit(state.copyWith(status: SettingsStatus.success, settings: settings));
    await _repository.saveSettings(settings);
  }

  Future<void> _onRequested(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final settings = await _repository.loadSettings();
    emit(state.copyWith(status: SettingsStatus.success, settings: settings));
  }

  Future<void> _onCleared(
    SettingsCleared event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final settings = await _repository.clearSettings();
    emit(state.copyWith(status: SettingsStatus.success, settings: settings));
  }
}
