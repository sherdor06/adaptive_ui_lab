import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/child.dart';
import '../../state/children_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';

class MChildDetailPage extends StatelessWidget {
  const MChildDetailPage({required this.child, super.key});

  final Child child;

  Future<void> _share(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppStrings.shareTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text(AppStrings.shareLink),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text(AppStrings.shareReport),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text(AppStrings.shareCall),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final bloc = context.read<ChildrenBloc>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
    if (confirmed != true) return;
    bloc.add(ChildDeleted(child));
    navigator.pop();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(child.avatar, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(child.name, style: theme.textTheme.headlineSmall)),
          Center(
            child: Text(
              child.kindergarten,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: Icon(
                child.arrivedToday ? Icons.check : Icons.close,
                size: 18,
              ),
              label: Text(arrivalLabel(child.arrivedToday)),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.detailAttendance,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: child.attendanceRate,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatAttendance(child.attendedDays, child.totalDays),
                      ),
                      Text(
                        formatPercent(child.attendanceRate),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text(AppStrings.detailGroup),
                  trailing: Text(child.groupName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text(AppStrings.detailBirthDate),
                  trailing: Text(formatDate(child.birthDate)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text(AppStrings.detailAttended),
                  trailing: Text('${child.attendedDays}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.highlight_off),
                  title: const Text(AppStrings.detailMissed),
                  trailing: Text('${child.missedDays}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _share(context),
            icon: const Icon(Icons.ios_share),
            label: const Text(AppStrings.share),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text(AppStrings.delete),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }
}
