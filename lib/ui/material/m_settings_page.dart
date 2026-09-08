import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app/app_restart_controller.dart';
import '../../core/platform/platform_controller.dart';
import '../../core/platform/ui_platform.dart';
import '../../data/models/app_settings.dart';
import '../../state/settings_bloc.dart';
import '../shared/app_strings.dart';
import '../shared/formatters.dart';

class MSettingsPage extends StatefulWidget {
  const MSettingsPage({super.key});

  @override
  State<MSettingsPage> createState() => _MSettingsPageState();
}

class _MSettingsPageState extends State<MSettingsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabSettings),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text(AppStrings.uiStyleMaterialBadge)),
          ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            previous.settings.parentName != current.settings.parentName &&
            current.settings.parentName != _nameController.text,
        listener: (context, state) =>
            _nameController.text = state.settings.parentName,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const _SectionHeader(title: AppStrings.sectionNotifications),
            const _NotificationsTile(),
            const _SoundTile(),
            const _SectionHeader(title: AppStrings.sectionAppearance),
            const _FontScaleRow(),
            const _ThemeModeGroup(),
            const _SectionHeader(title: AppStrings.sectionProfile),
            _ParentNameField(controller: _nameController),
            const SizedBox(height: 12),
            const _LanguageMenu(),
            const _BirthDateTile(),
            const _SectionHeader(title: AppStrings.sectionUiMode),
            const _UiModeHint(),
            const SizedBox(height: 8),
            const _UiModeSegment(),
            const SizedBox(height: 24),
            const _ClearAllButton(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  const _NotificationsTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.notifications,
    );
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: const Text(AppStrings.notificationsTitle),
      subtitle: const Text(AppStrings.notificationsSubtitle),
      trailing: Switch(
        value: value,
        onChanged: (next) => context.read<SettingsBloc>().add(
          SettingsNotificationsToggled(next),
        ),
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.soundAlerts,
    );
    return ListTile(
      leading: Checkbox(
        value: value,
        onChanged: (next) => context.read<SettingsBloc>().add(
          SettingsSoundToggled(next ?? false),
        ),
      ),
      title: const Text(AppStrings.soundTitle),
      onTap: () =>
          context.read<SettingsBloc>().add(SettingsSoundToggled(!value)),
    );
  }
}

class _FontScaleRow extends StatefulWidget {
  const _FontScaleRow();

  @override
  State<_FontScaleRow> createState() => _FontScaleRowState();
}

class _FontScaleRowState extends State<_FontScaleRow> {
  void _suggestRestart() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(AppStrings.refreshHint),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: AppStrings.refreshAction,
            onPressed: _applyAndRestart,
          ),
        ),
      );
  }

  void _applyAndRestart() {
    context.read<SettingsBloc>().add(const SettingsFontScaleApplied());
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    appRestartController.restart();
  }

  void _afterChange(double next) {
    final applied = context.read<SettingsBloc>().state.settings.fontScale;
    if (next == applied) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else {
      _suggestRestart();
    }
  }

  void _reset() {
    context.read<SettingsBloc>().add(const SettingsFontScaleReset());
    _afterChange(AppSettings.defaultFontScale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (pending, hasPending) = context.select(
      (SettingsBloc bloc) => (
        bloc.state.settings.pendingFontScale,
        bloc.state.settings.hasPendingFontScale,
      ),
    );
    final isDefault = pending == AppSettings.defaultFontScale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppStrings.fontScale,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(fontScaleLabel(pending)),
              const SizedBox(width: 4),
              TextButton(
                onPressed: isDefault ? null : _reset,
                child: const Text(AppStrings.fontScaleDefault),
              ),
            ],
          ),
          Slider(
            value: pending,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            label: fontScaleLabel(pending),
            onChanged: (next) => context.read<SettingsBloc>().add(
              SettingsFontScaleChanged(next),
            ),
            onChangeEnd: _afterChange,
          ),
          if (hasPending)
            Row(
              children: [
                Icon(
                  Icons.restart_alt,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.fontScalePending,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: _applyAndRestart,
                  child: const Text(AppStrings.refreshAction),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ThemeModeGroup extends StatelessWidget {
  const _ThemeModeGroup();

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.themeMode,
    );
    return RadioGroup<AppThemeMode>(
      groupValue: value,
      onChanged: (next) {
        if (next == null) return;
        context.read<SettingsBloc>().add(SettingsThemeModeChanged(next));
      },
      child: Column(
        children: [
          for (final mode in AppThemeMode.values)
            ListTile(
              leading: Radio<AppThemeMode>(value: mode),
              title: Text(themeModeLabel(mode)),
              onTap: () => context.read<SettingsBloc>().add(
                SettingsThemeModeChanged(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParentNameField extends StatelessWidget {
  const _ParentNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: AppStrings.parentName,
          hintText: AppStrings.parentNameHint,
          prefixIcon: Icon(Icons.person_outline),
        ),
        onChanged: (value) =>
            context.read<SettingsBloc>().add(SettingsParentNameChanged(value)),
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.language,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownMenu<AppLanguage>(
        key: ValueKey<AppLanguage>(value),
        initialSelection: value,
        label: const Text(AppStrings.language),
        expandedInsets: EdgeInsets.zero,
        onSelected: (next) {
          if (next == null) return;
          context.read<SettingsBloc>().add(SettingsLanguageChanged(next));
        },
        dropdownMenuEntries: [
          for (final language in AppLanguage.values)
            DropdownMenuEntry<AppLanguage>(
              value: language,
              label: languageLabel(language),
            ),
        ],
      ),
    );
  }
}

class _BirthDateTile extends StatelessWidget {
  const _BirthDateTile();

  Future<void> _pick(BuildContext context, DateTime current) async {
    final bloc = context.read<SettingsBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1950),
      lastDate: DateTime(2030),
      helpText: AppStrings.birthDate,
    );
    if (picked == null) return;
    bloc.add(SettingsBirthDateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final value = context.select(
      (SettingsBloc bloc) => bloc.state.settings.birthDate,
    );
    return ListTile(
      leading: const Icon(Icons.cake_outlined),
      title: const Text(AppStrings.birthDate),
      subtitle: Text(formatDate(value)),
      trailing: const Icon(Icons.calendar_month),
      onTap: () => _pick(context, value),
    );
  }
}

class _UiModeHint extends StatelessWidget {
  const _UiModeHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        AppStrings.uiModeSubtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _UiModeSegment extends StatelessWidget {
  const _UiModeSegment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<UiStyleMode>(
        valueListenable: platformController.mode,
        builder: (context, mode, _) => SegmentedButton<UiStyleMode>(
          segments: [
            for (final value in UiStyleMode.values)
              ButtonSegment<UiStyleMode>(
                value: value,
                label: Text(uiStyleModeLabel(value)),
              ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              platformController.setMode(selection.first),
        ),
      ),
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  const _ClearAllButton();

  Future<void> _clearAll(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text(AppStrings.clearTitle),
        content: const Text(AppStrings.clearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.clearAll),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    bloc.add(const SettingsCleared());
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(AppStrings.clearedToast),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton.tonalIcon(
        onPressed: () => _clearAll(context),
        icon: const Icon(Icons.delete_sweep_outlined),
        label: const Text(AppStrings.clearAll),
      ),
    );
  }
}
