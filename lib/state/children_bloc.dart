import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_repository.dart';
import '../data/models/child.dart';

enum ChildrenStatus { initial, loading, success, failure }

enum ChildrenFilter { all, arrivedToday }

sealed class ChildrenEvent extends Equatable {
  const ChildrenEvent();

  @override
  List<Object?> get props => const [];
}

final class ChildrenRequested extends ChildrenEvent {
  const ChildrenRequested();
}

final class ChildrenRefreshed extends ChildrenEvent {
  const ChildrenRefreshed();
}

final class ChildrenQueryChanged extends ChildrenEvent {
  const ChildrenQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ChildrenFilterChanged extends ChildrenEvent {
  const ChildrenFilterChanged(this.filter);

  final ChildrenFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class ChildDeleted extends ChildrenEvent {
  const ChildDeleted(this.child);

  final Child child;

  @override
  List<Object?> get props => [child];
}

final class ChildDeleteUndone extends ChildrenEvent {
  const ChildDeleteUndone();
}

class ChildrenState extends Equatable {
  ChildrenState({
    this.status = ChildrenStatus.initial,
    this.children = const <Child>[],
    this.query = '',
    this.filter = ChildrenFilter.all,
    this.errorMessage = '',
    this.lastDeleted,
    this.lastDeletedIndex = -1,
  });

  final ChildrenStatus status;
  final List<Child> children;
  final String query;
  final ChildrenFilter filter;
  final String errorMessage;
  final Child? lastDeleted;
  final int lastDeletedIndex;

  factory ChildrenState.initial() => ChildrenState();

  late final List<Child> visibleChildren = _applyFilters();

  List<Child> _applyFilters() {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty && filter == ChildrenFilter.all) {
      return children;
    }
    return children
        .where((child) {
          final matchesQuery =
              normalized.isEmpty ||
              child.name.toLowerCase().contains(normalized) ||
              child.kindergarten.toLowerCase().contains(normalized) ||
              child.groupName.toLowerCase().contains(normalized);
          final matchesFilter =
              filter == ChildrenFilter.all || child.arrivedToday;
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }

  bool get isEmptyResult =>
      status == ChildrenStatus.success && visibleChildren.isEmpty;

  bool get canUndo => lastDeleted != null;

  ChildrenState copyWith({
    ChildrenStatus? status,
    List<Child>? children,
    String? query,
    ChildrenFilter? filter,
    String? errorMessage,
    Child? lastDeleted,
    int? lastDeletedIndex,
    bool clearLastDeleted = false,
  }) {
    return ChildrenState(
      status: status ?? this.status,
      children: children ?? this.children,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      lastDeleted: clearLastDeleted ? null : (lastDeleted ?? this.lastDeleted),
      lastDeletedIndex: clearLastDeleted
          ? -1
          : (lastDeletedIndex ?? this.lastDeletedIndex),
    );
  }

  @override
  List<Object?> get props => [
    status,
    children,
    query,
    filter,
    errorMessage,
    lastDeleted,
    lastDeletedIndex,
  ];
}

class ChildrenBloc extends Bloc<ChildrenEvent, ChildrenState> {
  ChildrenBloc(this._repository) : super(ChildrenState.initial()) {
    on<ChildrenRequested>(_onRequested);
    on<ChildrenRefreshed>(_onRefreshed);
    on<ChildrenQueryChanged>(_onQueryChanged);
    on<ChildrenFilterChanged>(_onFilterChanged);
    on<ChildDeleted>(_onDeleted);
    on<ChildDeleteUndone>(_onDeleteUndone);
  }

  final FakeRepository _repository;

  Future<void> _load(Emitter<ChildrenState> emit) async {
    emit(state.copyWith(status: ChildrenStatus.loading, errorMessage: ''));
    try {
      final children = await _repository.fetchChildren();
      emit(
        state.copyWith(
          status: ChildrenStatus.success,
          children: children,
          errorMessage: '',
        ),
      );
    } on RepositoryFailure catch (failure) {
      emit(
        state.copyWith(
          status: ChildrenStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _onRequested(
    ChildrenRequested event,
    Emitter<ChildrenState> emit,
  ) => _load(emit);

  Future<void> _onRefreshed(
    ChildrenRefreshed event,
    Emitter<ChildrenState> emit,
  ) => _load(emit);

  void _onQueryChanged(
    ChildrenQueryChanged event,
    Emitter<ChildrenState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  void _onFilterChanged(
    ChildrenFilterChanged event,
    Emitter<ChildrenState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onDeleted(
    ChildDeleted event,
    Emitter<ChildrenState> emit,
  ) async {
    final index = state.children.indexOf(event.child);
    final updated = state.children
        .where((c) => c.id != event.child.id)
        .toList();
    emit(
      state.copyWith(
        children: updated,
        lastDeleted: event.child,
        lastDeletedIndex: index,
      ),
    );
    await _repository.deleteChild(event.child.id);
  }

  Future<void> _onDeleteUndone(
    ChildDeleteUndone event,
    Emitter<ChildrenState> emit,
  ) async {
    final child = state.lastDeleted;
    if (child == null) return;
    final index = state.lastDeletedIndex;
    final updated = List<Child>.of(state.children)
      ..insert(index < 0 ? 0 : index.clamp(0, state.children.length), child);
    emit(state.copyWith(children: updated, clearLastDeleted: true));
    await _repository.restoreChild(child, index);
  }
}
