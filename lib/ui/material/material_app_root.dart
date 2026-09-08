import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_settings.dart';
import '../../state/settings_bloc.dart';
import '../shared/app_strings.dart';
import 'm_home_shell.dart';

class MaterialAppRoot extends StatelessWidget {
  const MaterialAppRoot({super.key});

  static const Color _seed = Color(0xFF3F6FD8);

  ThemeData _themeFor(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
    );
  }

  ThemeMode _themeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.themeMode != current.settings.themeMode ||
          previous.settings.fontScale != current.settings.fontScale,
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appTitle,
          theme: _themeFor(Brightness.light),
          darkTheme: _themeFor(Brightness.dark),
          themeMode: _themeMode(state.settings.themeMode),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: state.settings.fontScale,
            maxScaleFactor: state.settings.fontScale,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const MHomeShell(),
        );
      },
    );
  }
}
