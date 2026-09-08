import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/schedule_item.dart';
import '../../state/schedule_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';

class MSchedulePage extends StatefulWidget {
  const MSchedulePage({super.key});

  @override
  State<MSchedulePage> createState() => _MSchedulePageState();
}

class _MSchedulePageState extends State<MSchedulePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ScheduleBloc>();
    _tabController = TabController(
      length: ScheduleScope.values.length,
      vsync: this,
      initialIndex: ScheduleScope.values.indexOf(bloc.state.scope),
    );
    _tabController.addListener(_onTabChanged);
    if (bloc.state.status == ScheduleStatus.initial) {
      bloc.add(const ScheduleRequested());
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<ScheduleBloc>().add(
      ScheduleScopeChanged(ScheduleScope.values[_tabController.index]),
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabSchedule),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            for (final scope in ScheduleScope.values)
              Tab(text: scopeLabel(scope)),
          ],
        ),
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage ||
            !identical(previous.todayItems, current.todayItems) ||
            !identical(previous.weekItems, current.weekItems),
        builder: (context, state) {
          if (state.status == ScheduleStatus.loading ||
              state.status == ScheduleStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ScheduleStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<ScheduleBloc>().add(
                      const ScheduleRequested(),
                    ),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              for (final scope in ScheduleScope.values)
                _ScopeList(sections: state.sectionsFor(scope)),
            ],
          );
        },
      ),
    );
  }
}

class _ScopeList extends StatelessWidget {
  const _ScopeList({required this.sections});

  final Map<ScheduleGroup, List<ScheduleItem>> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = sections.entries.toList(growable: false);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                scheduleGroupTitle(entry.key).toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (var i = 0; i < entry.value.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 72),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: entry.value[i].done
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          entry.value[i].done
                              ? Icons.check
                              : Icons.access_time_outlined,
                          size: 20,
                        ),
                      ),
                      title: Text(entry.value[i].title),
                      subtitle: Text(entry.value[i].subtitle),
                      trailing: Text(
                        formatClock(entry.value[i].hour, entry.value[i].minute),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
