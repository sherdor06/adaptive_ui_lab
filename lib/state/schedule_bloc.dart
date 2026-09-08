import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_repository.dart';
import '../data/models/schedule_item.dart';

enum ScheduleStatus { initial, loading, success, failure }

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => const [];
}

final class ScheduleRequested extends ScheduleEvent {
  const ScheduleRequested();
}

final class ScheduleScopeChanged extends ScheduleEvent {
  const ScheduleScopeChanged(this.scope);

  final ScheduleScope scope;

  @override
  List<Object?> get props => [scope];
}

class ScheduleState extends Equatable {
  ScheduleState({
    this.status = ScheduleStatus.initial,
    this.scope = ScheduleScope.today,
    this.todayItems = const <ScheduleItem>[],
    this.weekItems = const <ScheduleItem>[],
    this.errorMessage = '',
  });

  final ScheduleStatus status;
  final ScheduleScope scope;
  final List<ScheduleItem> todayItems;
  final List<ScheduleItem> weekItems;
  final String errorMessage;

  factory ScheduleState.initial() => ScheduleState();

  late final Map<ScheduleGroup, List<ScheduleItem>> todaySections =
      _groupByGroup(todayItems);

  late final Map<ScheduleGroup, List<ScheduleItem>> weekSections =
      _groupByGroup(weekItems);

  List<ScheduleItem> get items => itemsFor(scope);

  List<ScheduleItem> itemsFor(ScheduleScope value) =>
      value == ScheduleScope.today ? todayItems : weekItems;

  Map<ScheduleGroup, List<ScheduleItem>> sectionsFor(ScheduleScope value) =>
      value == ScheduleScope.today ? todaySections : weekSections;

  static Map<ScheduleGroup, List<ScheduleItem>> _groupByGroup(
    List<ScheduleItem> items,
  ) {
    final sections = <ScheduleGroup, List<ScheduleItem>>{};
    for (final item in items) {
      sections.putIfAbsent(item.group, () => <ScheduleItem>[]).add(item);
    }
    return sections;
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    ScheduleScope? scope,
    List<ScheduleItem>? todayItems,
    List<ScheduleItem>? weekItems,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      scope: scope ?? this.scope,
      todayItems: todayItems ?? this.todayItems,
      weekItems: weekItems ?? this.weekItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    scope,
    todayItems,
    weekItems,
    errorMessage,
  ];
}

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(this._repository) : super(ScheduleState.initial()) {
    on<ScheduleRequested>(_onRequested);
    on<ScheduleScopeChanged>(_onScopeChanged);
  }

  final FakeRepository _repository;

  Future<void> _onRequested(
    ScheduleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading, errorMessage: ''));
    try {
      final results = await Future.wait([
        _repository.fetchSchedule(ScheduleScope.today),
        _repository.fetchSchedule(ScheduleScope.week),
      ]);
      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          todayItems: results.first,
          weekItems: results.last,
          errorMessage: '',
        ),
      );
    } on RepositoryFailure catch (failure) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  void _onScopeChanged(
    ScheduleScopeChanged event,
    Emitter<ScheduleState> emit,
  ) {
    emit(state.copyWith(scope: event.scope));
  }
}
