import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/child.dart';
import '../../state/children_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';
import 'c_toast.dart';

class CChildDetailPage extends StatelessWidget {
  const CChildDetailPage({required this.child, super.key});

  final Child child;

  Future<void> _share(BuildContext context) async {
    HapticFeedback.selectionClick();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: const Text(AppStrings.shareTitle),
        message: Text(child.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text(AppStrings.shareLink),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text(AppStrings.shareReport),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text(AppStrings.shareCall),
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

  Future<void> _delete(BuildContext context) async {
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
    final navigator = Navigator.of(context);
    final rootContext = navigator.context;
    bloc.add(ChildDeleted(child));
    navigator.pop();
    CToast.show(
      rootContext,
      message: '${child.name} ${AppStrings.deletedToast}',
      actionLabel: AppStrings.undo,
      onAction: () => bloc.add(const ChildDeleteUndone()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: AppStrings.tabChildren,
        middle: Text(child.name),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _share(context),
          child: const Icon(CupertinoIcons.share),
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 16),
            Center(
              child: CupertinoContextMenu(
                actions: [
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.share,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.share),
                  ),
                  CupertinoContextMenuAction(
                    isDestructiveAction: true,
                    trailingIcon: CupertinoIcons.delete,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.delete),
                  ),
                ],
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    child.avatar,
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(child.name, style: textTheme.navLargeTitleTextStyle),
            ),
            Center(
              child: Text(
                child.kindergarten,
                style: textTheme.tabLabelTextStyle,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                arrivalLabel(child.arrivedToday),
                style: textTheme.textStyle.copyWith(
                  color: child.arrivedToday
                      ? CupertinoColors.activeGreen.resolveFrom(context)
                      : CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
            CupertinoListSection.insetGrouped(
              header: const Text(AppStrings.detailAttendance),
              children: [
                CupertinoListTile.notched(
                  title: const Text(AppStrings.detailAttended),
                  additionalInfo: Text('${child.attendedDays}'),
                ),
                CupertinoListTile.notched(
                  title: const Text(AppStrings.detailMissed),
                  additionalInfo: Text('${child.missedDays}'),
                ),
                CupertinoListTile.notched(
                  title: const Text(AppStrings.detailAttendance),
                  additionalInfo: Text(formatPercent(child.attendanceRate)),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  title: const Text(AppStrings.detailGroup),
                  additionalInfo: Text(child.groupName),
                ),
                CupertinoListTile.notched(
                  title: const Text(AppStrings.detailBirthDate),
                  additionalInfo: Text(formatDate(child.birthDate)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () => _share(context),
                      child: const Text(AppStrings.share),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                      onPressed: () => _delete(context),
                      child: Text(
                        AppStrings.delete,
                        style: TextStyle(
                          color: CupertinoColors.destructiveRed.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
