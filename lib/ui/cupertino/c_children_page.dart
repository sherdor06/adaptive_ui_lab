import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/child.dart';
import '../../state/children_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';
import '../shared/rebuild_guards.dart';
import 'c_child_detail_page.dart';
import 'c_toast.dart';

void _showAddHint(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (popupContext) => CupertinoActionSheet(
      title: const Text(AppStrings.add),
      message: const Text(AppStrings.addHint),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(popupContext).pop(),
        child: const Text(AppStrings.cancel),
      ),
    ),
  );
}

class CChildrenPage extends StatefulWidget {
  const CChildrenPage({super.key});

  @override
  State<CChildrenPage> createState() => _CChildrenPageState();
}

class _CChildrenPageState extends State<CChildrenPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ChildrenBloc>();
    _searchController.text = bloc.state.query;
    if (bloc.state.status == ChildrenStatus.initial) {
      bloc.add(const ChildrenRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final bloc = context.read<ChildrenBloc>();
    bloc.add(const ChildrenRefreshed());
    return bloc.stream.firstWhere(
      (state) => state.status != ChildrenStatus.loading,
    );
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
          const _ChildrenNavBar(),
          CupertinoSliverRefreshControl(onRefresh: _refresh),
          SliverToBoxAdapter(
            child: _ChildrenSearchField(controller: _searchController),
          ),
          const SliverToBoxAdapter(child: _ChildrenFilterSegment()),
          const _ChildrenBody(),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 32),
          ),
        ],
      ),
    );
  }
}

class _ChildrenNavBar extends StatelessWidget {
  const _ChildrenNavBar();

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: const Text(AppStrings.tabChildren),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showAddHint(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class _ChildrenSearchField extends StatelessWidget {
  const _ChildrenSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: CupertinoSearchTextField(
        controller: controller,
        placeholder: AppStrings.searchHint,
        onChanged: (value) =>
            context.read<ChildrenBloc>().add(ChildrenQueryChanged(value)),
        onSuffixTap: () {
          controller.clear();
          context.read<ChildrenBloc>().add(const ChildrenQueryChanged(''));
        },
      ),
    );
  }
}

class _ChildrenFilterSegment extends StatelessWidget {
  const _ChildrenFilterSegment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: BlocSelector<ChildrenBloc, ChildrenState, ChildrenFilter>(
          selector: (state) => state.filter,
          builder: (context, filter) {
            return CupertinoSlidingSegmentedControl<ChildrenFilter>(
              groupValue: filter,
              onValueChanged: (value) {
                if (value == null) return;
                HapticFeedback.selectionClick();
                context.read<ChildrenBloc>().add(ChildrenFilterChanged(value));
              },
              children: {
                for (final value in ChildrenFilter.values)
                  value: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(filterLabel(value)),
                  ),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChildrenBody extends StatelessWidget {
  const _ChildrenBody();

  void _openDetail(BuildContext context, Child child) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        title: AppStrings.tabChildren,
        builder: (_) => CChildDetailPage(child: child),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Child child) async {
    final bloc = context.read<ChildrenBloc>();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text(AppStrings.deleteTitle),
        content: Text('\n${child.name} — ${AppStrings.deleteMessage}'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    HapticFeedback.mediumImpact();
    bloc.add(ChildDeleted(child));
    CToast.show(
      context,
      message: '${child.name} ${AppStrings.deletedToast}',
      actionLabel: AppStrings.undo,
      onAction: () => bloc.add(const ChildDeleteUndone()),
    );
  }

  Future<void> _showActions(BuildContext context, Child child) async {
    HapticFeedback.selectionClick();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: Text(child.name),
        message: Text(child.kindergarten),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(popupContext).pop();
              _openDetail(context, child);
            },
            child: const Text('Batafsil'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text(AppStrings.shareLink),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(popupContext).pop();
              _confirmDelete(context, child);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(popupContext).pop(),
          child: const Text(AppStrings.cancel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return BlocBuilder<ChildrenBloc, ChildrenState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          !sameChildren(previous.visibleChildren, current.visibleChildren),
      builder: (context, state) {
        switch (state.status) {
          case ChildrenStatus.initial:
          case ChildrenStatus.loading:
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CupertinoActivityIndicator(radius: 16)),
              ),
            );
          case ChildrenStatus.failure:
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.wifi_exclamationmark,
                      size: 56,
                      color: CupertinoColors.systemRed.resolveFrom(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.errorTitle,
                      style: textTheme.navTitleTextStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: textTheme.tabLabelTextStyle,
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: () => context.read<ChildrenBloc>().add(
                        const ChildrenRequested(),
                      ),
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            );
          case ChildrenStatus.success:
            final visible = state.visibleChildren;
            if (visible.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.search, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.emptyTitle,
                        style: textTheme.navTitleTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.emptySubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.tabLabelTextStyle,
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                header: Text('${visible.length} ta bola'),
                children: [
                  for (final child in visible)
                    _ChildTile(
                      key: ValueKey<String>(child.id),
                      child: child,
                      onTap: () => _openDetail(context, child),
                      onLongPress: () => _showActions(context, child),
                    ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Child child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: CupertinoListTile.notched(
        leading: Text(child.avatar, style: const TextStyle(fontSize: 24)),
        title: Text(child.name),
        subtitle: Text('${child.kindergarten} · ${child.groupName}'),
        additionalInfo: Text(formatPercent(child.attendanceRate)),
        trailing: const CupertinoListTileChevron(),
        onTap: onTap,
      ),
    );
  }
}
