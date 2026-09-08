import 'package:equatable/equatable.dart';

enum AppLanguage { uzbek, russian, english }

enum AppThemeMode { system, light, dark }

class AppSettings extends Equatable {
  const AppSettings({
    required this.notifications,
    required this.soundAlerts,
    required this.fontScale,
    required this.pendingFontScale,
    required this.language,
    required this.themeMode,
    required this.birthDate,
    required this.parentName,
  });

  static const double defaultFontScale = 1;

  factory AppSettings.defaults() => AppSettings(
    notifications: true,
    soundAlerts: false,
    fontScale: defaultFontScale,
    pendingFontScale: defaultFontScale,
    language: AppLanguage.uzbek,
    themeMode: AppThemeMode.system,
    birthDate: DateTime(1992, 4, 17),
    parentName: 'Sherdor',
  );

  final bool notifications;
  final bool soundAlerts;
  final double fontScale;
  final double pendingFontScale;
  final AppLanguage language;
  final AppThemeMode themeMode;
  final DateTime birthDate;
  final String parentName;

  bool get hasPendingFontScale => pendingFontScale != fontScale;

  AppSettings copyWith({
    bool? notifications,
    bool? soundAlerts,
    double? fontScale,
    double? pendingFontScale,
    AppLanguage? language,
    AppThemeMode? themeMode,
    DateTime? birthDate,
    String? parentName,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      soundAlerts: soundAlerts ?? this.soundAlerts,
      fontScale: fontScale ?? this.fontScale,
      pendingFontScale: pendingFontScale ?? this.pendingFontScale,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      birthDate: birthDate ?? this.birthDate,
      parentName: parentName ?? this.parentName,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    soundAlerts,
    fontScale,
    pendingFontScale,
    language,
    themeMode,
    birthDate,
    parentName,
  ];
}
