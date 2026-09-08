import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_settings.dart';
import '../../state/settings_bloc.dart';
import '../shared/app_strings.dart';
import 'c_tabs_shell.dart';

class CupertinoAppRoot extends StatelessWidget {
  const CupertinoAppRoot({super.key});

  Brightness? _brightness(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => null,
    AppThemeMode.light => Brightness.light,
    AppThemeMode.dark => Brightness.dark,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.themeMode != current.settings.themeMode ||
          previous.settings.fontScale != current.settings.fontScale,
      builder: (context, state) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appTitle,
          theme: CupertinoThemeData(
            brightness: _brightness(state.settings.themeMode),
            primaryColor: CupertinoColors.systemIndigo,
          ),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: state.settings.fontScale,
            maxScaleFactor: state.settings.fontScale,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const CTabsShell(),
        );
      },
    );
  }
}
