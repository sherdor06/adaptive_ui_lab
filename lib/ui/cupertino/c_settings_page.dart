import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app/app_restart_controller.dart';
import '../../core/platform/platform_controller.dart';
import '../../core/platform/ui_platform.dart';
import '../../data/models/app_settings.dart';
import '../../state/settings_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';
import 'c_toast.dart';

Widget _pickerFrame(BuildContext popupContext, Widget child) {
  return Container(
    height: 300,
    color: CupertinoColors.systemBackground.resolveFrom(popupContext),
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                onPressed: () => Navigator.of(popupContext).pop(),
                child: const Text('Tayyor'),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class CSettingsPage extends StatefulWidget {
  const CSettingsPage({super.key});

  @override
  State<CSettingsPage> createState() => _CSettingsPageState();
}

class _CSettingsPageState extends State<CSettingsPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SettingsBloc>();
    _nameController = TextEditingController(
      text: bloc.state.settings.parentName,
    );
    if (bloc.state.status == SettingsStatus.initial) {
      bloc.add(const SettingsRequested());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            previous.settings.parentName != current.settings.parentName &&
            current.settings.parentName != _nameController.text,
        listener: (context, state) =>
            _nameController.text = state.settings.parentName,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const CupertinoSliverNavigationBar(
              largeTitle: Text(AppStrings.tabSettings),
              trailing: Text(AppStrings.uiStyleCupertinoBadge),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              sliver: SliverList.list(
                children: [
                  const _NotificationsSection(),
                  const _FontScaleSection(),
                  const _ThemeModeSection(),
                  _ProfileSection(controller: _nameController),
                  const _PickersSection(),
                  const _UiModeSection(),
                  const _ClearAllButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    final notifications = context.select(
      (SettingsBloc bloc) => bloc.state.settings.notifications,
    );
    final sound = context.select(
      (SettingsBloc bloc) => bloc.state.settings.soundAlerts,
    );
    return CupertinoListSection.insetGrouped(
      header: const Text(AppStrings.sectionNotifications),
      children: [
        CupertinoListTile.notched(
          title: const Text(AppStrings.notificationsTitle),
          subtitle: const Text(AppStrings.notificationsSubtitle),
          trailing: CupertinoSwitch(
            value: notifications,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              context.read<SettingsBloc>().add(
                SettingsNotificationsToggled(value),
              );
            },
          ),
        ),
        CupertinoListTile.notched(
          title: const Text(AppStrings.soundTitle),
          trailing: CupertinoCheckbox(
            value: sound,
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsSoundToggled(value ?? false),
            ),
          ),
        ),
      ],
    );
  }
}

class _FontScaleSection extends StatefulWidget {
  const _FontScaleSection();

  @override
  State<_FontScaleSection> createState() => _FontScaleSectionState();
}

class _FontScaleSectionState extends State<_FontScaleSection> {
  void _suggestRestart() {
    CToast.show(
      context,
      message: AppStrings.refreshHint,
      actionLabel: AppStrings.refreshAction,
      onAction: _applyAndRestart,
    );
  }

  void _applyAndRestart() {
    context.read<SettingsBloc>().add(const SettingsFontScaleApplied());
    appRestartController.restart();
  }

  void _afterChange(double next) {
    final applied = context.read<SettingsBloc>().state.settings.fontScale;
    if (next != applied) _suggestRestart();
  }

  void _reset() {
    HapticFeedback.selectionClick();
    context.read<SettingsBloc>().add(const SettingsFontScaleReset());
    _afterChange(AppSettings.defaultFontScale);
  }

  @override
  Widget build(BuildContext context) {
    final (pending, hasPending) = context.select(
      (SettingsBloc bloc) => (
        bloc.state.settings.pendingFontScale,
        bloc.state.settings.hasPendingFontScale,
      ),
    );
    final isDefault = pending == AppSettings.defaultFontScale;
    return CupertinoListSection.insetGrouped(
      header: const Text(AppStrings.sectionAppearance),
      footer: hasPending ? const Text(AppStrings.fontScalePending) : null,
      children: [
        CupertinoListTile.notched(
          title: const Text(AppStrings.fontScale),
          additionalInfo: Text(fontScaleLabel(pending)),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isDefault ? null : _reset,
            child: const Text(AppStrings.fontScaleDefault),
          ),
          subtitle: CupertinoSlider(
            value: pending,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            onChanged: (next) => context.read<SettingsBloc>().add(
              SettingsFontScaleChanged(next),
            ),
            onChangeEnd: _afterChange,
          ),
        ),
        if (hasPending)
          CupertinoListTile.notched(
            leading: Icon(
              CupertinoIcons.arrow_clockwise,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
            title: Text(
              AppStrings.refreshAction,
              style: TextStyle(
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
            trailing: const CupertinoListTileChevron(),
            onTap: _applyAndRestart,
          ),
      ],
    );
  }
}

class _ThemeModeSection extends StatelessWidget {
  const _ThemeModeSection();

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.themeMode,
    );
    return RadioGroup<AppThemeMode>(
      groupValue: value,
      onChanged: (next) {
        if (next != null) {
          context.read<SettingsBloc>().add(SettingsThemeModeChanged(next));
        }
      },
      child: CupertinoListSection.insetGrouped(
        header: const Text(AppStrings.themeMode),
        children: [
          for (final mode in AppThemeMode.values)
            CupertinoListTile.notched(
              title: Text(themeModeLabel(mode)),
              trailing: CupertinoRadio<AppThemeMode>(value: mode),
              onTap: () => context.read<SettingsBloc>().add(
                SettingsThemeModeChanged(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: const Text(AppStrings.sectionProfile),
      children: [
        CupertinoFormRow(
          prefix: const Text(AppStrings.parentName),
          child: CupertinoTextField.borderless(
            controller: controller,
            placeholder: AppStrings.parentNameHint,
            textAlign: TextAlign.end,
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsParentNameChanged(value),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickersSection extends StatelessWidget {
  const _PickersSection();

  Future<void> _pickLanguage(BuildContext context, AppLanguage current) async {
    final bloc = context.read<SettingsBloc>();
    final controller = FixedExtentScrollController(
      initialItem: AppLanguage.values.indexOf(current),
    );
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => _pickerFrame(
        popupContext,
        CupertinoPicker(
          scrollController: controller,
          itemExtent: 36,
          onSelectedItemChanged: (index) {
            HapticFeedback.selectionClick();
            bloc.add(SettingsLanguageChanged(AppLanguage.values[index]));
          },
          children: [
            for (final language in AppLanguage.values)
              Center(child: Text(languageLabel(language))),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _pickBirthDate(BuildContext context, DateTime current) async {
    final bloc = context.read<SettingsBloc>();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => _pickerFrame(
        popupContext,
        CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: current,
          minimumDate: DateTime(1950),
          maximumDate: DateTime(2030),
          onDateTimeChanged: (value) =>
              bloc.add(SettingsBirthDateChanged(value)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.select(
      (SettingsBloc bloc) => bloc.state.settings.language,
    );
    final birthDate = context.select(
      (SettingsBloc bloc) => bloc.state.settings.birthDate,
    );
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile.notched(
          title: const Text(AppStrings.language),
          additionalInfo: Text(languageLabel(language)),
          trailing: const CupertinoListTileChevron(),
          onTap: () => _pickLanguage(context, language),
        ),
        CupertinoListTile.notched(
          title: const Text(AppStrings.birthDate),
          additionalInfo: Text(formatDate(birthDate)),
          trailing: const CupertinoListTileChevron(),
          onTap: () => _pickBirthDate(context, birthDate),
        ),
      ],
    );
  }
}

class _UiModeSection extends StatelessWidget {
  const _UiModeSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            AppStrings.sectionUiMode,
            style: textTheme.navTitleTextStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ValueListenableBuilder<UiStyleMode>(
            valueListenable: platformController.mode,
            builder: (context, mode, _) =>
                CupertinoSlidingSegmentedControl<UiStyleMode>(
                  groupValue: mode,
                  onValueChanged: (value) {
                    if (value == null) return;
                    HapticFeedback.selectionClick();
                    platformController.setMode(value);
                  },
                  children: {
                    for (final value in UiStyleMode.values)
                      value: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(uiStyleModeLabel(value)),
                      ),
                  },
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            AppStrings.uiModeSubtitle,
            style: textTheme.tabLabelTextStyle,
          ),
        ),
      ],
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  const _ClearAllButton();

  Future<void> _clearAll(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text(AppStrings.clearTitle),
        content: const Text('\n${AppStrings.clearMessage}'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.clearAll),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    HapticFeedback.mediumImpact();
    bloc.add(const SettingsCleared());
    CToast.show(context, message: AppStrings.clearedToast);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          onPressed: () => _clearAll(context),
          child: Text(
            AppStrings.clearAll,
            style: textTheme.textStyle.copyWith(
              color: CupertinoColors.destructiveRed.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}
