import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/child.dart';
import '../../state/children_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';
import '../shared/rebuild_guards.dart';
import 'm_child_detail_page.dart';

void _showAddHint(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(AppStrings.addHint),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class MChildrenPage extends StatefulWidget {
  const MChildrenPage({super.key});

  @override
  State<MChildrenPage> createState() => _MChildrenPageState();
}

class _MChildrenPageState extends State<MChildrenPage> {
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHint(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _ChildrenAppBar(),
            SliverToBoxAdapter(
              child: _ChildrenSearchField(controller: _searchController),
            ),
            const SliverToBoxAdapter(child: _ChildrenFilterRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const _ChildrenBody(),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }
}

class _ChildrenAppBar extends StatelessWidget {
  const _ChildrenAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      title: const Text(AppStrings.tabChildren),
      actions: [
        IconButton(
          tooltip: AppStrings.uiStyleMaterialBadge,
          onPressed: () => _showAddHint(context),
          icon: const Icon(Icons.android),
        ),
      ],
    );
  }
}

class _ChildrenSearchField extends StatelessWidget {
  const _ChildrenSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SearchBar(
        controller: controller,
        hintText: AppStrings.searchHint,
        leading: const Icon(Icons.search),
        trailing: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  context.read<ChildrenBloc>().add(
                    const ChildrenQueryChanged(''),
                  );
                },
              );
            },
          ),
        ],
        onChanged: (value) =>
            context.read<ChildrenBloc>().add(ChildrenQueryChanged(value)),
      ),
    );
  }
}

class _ChildrenFilterRow extends StatelessWidget {
  const _ChildrenFilterRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<ChildrenBloc, ChildrenState, (ChildrenFilter, int)>(
      selector: (state) => (state.filter, state.visibleChildren.length),
      builder: (context, data) {
        final (selected, count) = data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final filter in ChildrenFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filterLabel(filter)),
                            selected: selected == filter,
                            onSelected: (_) => context.read<ChildrenBloc>().add(
                              ChildrenFilterChanged(filter),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Text('$count', style: theme.textTheme.labelLarge),
            ],
          ),
        );
      },
    );
  }
}

class _ChildrenBody extends StatelessWidget {
  const _ChildrenBody();

  Future<bool> _confirmDelete(BuildContext context, Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text(AppStrings.deleteTitle),
        content: Text('${child.name} — ${AppStrings.deleteMessage}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _delete(BuildContext context, Child child) {
    final bloc = context.read<ChildrenBloc>();
    final messenger = ScaffoldMessenger.of(context);
    bloc.add(ChildDeleted(child));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${child.name} ${AppStrings.deletedToast}'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: AppStrings.undo,
            onPressed: () => bloc.add(const ChildDeleteUndone()),
          ),
        ),
      );
  }

  void _openDetail(BuildContext context, Child child) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => MChildDetailPage(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    LinearProgressIndicator(),
                  ],
                ),
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
                      Icons.cloud_off,
                      size: 56,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.errorTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<ChildrenBloc>().add(
                        const ChildrenRequested(),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.retry),
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
                      const Icon(Icons.search_off, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.emptyTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.emptySubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 88),
              itemBuilder: (context, index) {
                final child = visible[index];
                return _ChildCard(
                  key: ValueKey<String>(child.id),
                  child: child,
                  onTap: () => _openDetail(context, child),
                  onConfirmDelete: () => _confirmDelete(context, child),
                  onDeleted: () => _delete(context, child),
                );
              },
            );
        }
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onConfirmDelete,
    required this.onDeleted,
    super.key,
  });

  final Child child;
  final VoidCallback onTap;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey<String>('dismiss-${child.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDeleted(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(child.avatar),
          ),
          title: Text(child.name),
          subtitle: Text('${child.kindergarten} · ${child.groupName}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPercent(child.attendanceRate),
                style: theme.textTheme.labelLarge,
              ),
              Icon(
                child.arrivedToday
                    ? Icons.check_circle
                    : Icons.remove_circle_outline,
                size: 18,
                color: child.arrivedToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
