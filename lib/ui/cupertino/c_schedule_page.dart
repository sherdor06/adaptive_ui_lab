import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/schedule_item.dart';
import '../../state/schedule_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';

class CSchedulePage extends StatefulWidget {
  const CSchedulePage({super.key});

  @override
  State<CSchedulePage> createState() => _CSchedulePageState();
}

class _CSchedulePageState extends State<CSchedulePage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ScheduleBloc>();
    if (bloc.state.status == ScheduleStatus.initial) {
      bloc.add(const ScheduleRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text(AppStrings.tabSchedule),
          ),
          const SliverToBoxAdapter(child: _ScopeSegment()),
          const _ScheduleBody(),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 32),
          ),
        ],
      ),
    );
  }
}

class _ScopeSegment extends StatelessWidget {
  const _ScopeSegment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: BlocSelector<ScheduleBloc, ScheduleState, ScheduleScope>(
          selector: (state) => state.scope,
          builder: (context, scope) {
            return CupertinoSlidingSegmentedControl<ScheduleScope>(
              groupValue: scope,
              onValueChanged: (value) {
                if (value == null) return;
                HapticFeedback.selectionClick();
                context.read<ScheduleBloc>().add(ScheduleScopeChanged(value));
              },
              children: {
                for (final value in ScheduleScope.values)
                  value: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(scopeLabel(value)),
                  ),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.scope != current.scope ||
          previous.errorMessage != current.errorMessage ||
          !identical(previous.todayItems, current.todayItems) ||
          !identical(previous.weekItems, current.weekItems),
      builder: (context, state) {
        if (state.status == ScheduleStatus.loading ||
            state.status == ScheduleStatus.initial) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CupertinoActivityIndicator(radius: 16)),
          );
        }
        if (state.status == ScheduleStatus.failure) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage, style: textTheme.textStyle),
                  const SizedBox(height: 12),
                  CupertinoButton.filled(
                    onPressed: () => context.read<ScheduleBloc>().add(
                      const ScheduleRequested(),
                    ),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          );
        }
        final sections = state
            .sectionsFor(state.scope)
            .entries
            .toList(growable: false);
        return SliverList.builder(
          itemCount: sections.length,
          itemBuilder: (context, index) => _ScheduleSection(
            key: ValueKey<ScheduleGroup>(sections[index].key),
            group: sections[index].key,
            items: sections[index].value,
          ),
        );
      },
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.group, required this.items, super.key});

  final ScheduleGroup group;
  final List<ScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(scheduleGroupTitle(group)),
      children: [
        for (final item in items)
          CupertinoListTile.notched(
            key: ValueKey<String>(item.id),
            leading: Icon(
              item.done
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: item.done
                  ? CupertinoColors.activeGreen.resolveFrom(context)
                  : CupertinoColors.systemGrey.resolveFrom(context),
            ),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            additionalInfo: Text(formatClock(item.hour, item.minute)),
          ),
      ],
    );
  }
}
