import '../../core/platform/ui_platform.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/schedule_item.dart';
import '../../state/children_bloc.dart';
import 'app_strings.dart';

String formatClock(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}

String formatPercent(double value) => '${(value * 100).round()}%';

String formatAttendance(int attended, int total) => '$attended / $total kun';

String languageLabel(AppLanguage language) => switch (language) {
  AppLanguage.uzbek => 'Oʻzbekcha',
  AppLanguage.russian => 'Русский',
  AppLanguage.english => 'English',
};

String themeModeLabel(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => AppStrings.themeSystem,
  AppThemeMode.light => AppStrings.themeLight,
  AppThemeMode.dark => AppStrings.themeDark,
};

String uiStyleModeLabel(UiStyleMode mode) => switch (mode) {
  UiStyleMode.system => AppStrings.uiSystem,
  UiStyleMode.forceMaterial => AppStrings.uiMaterial,
  UiStyleMode.forceCupertino => AppStrings.uiCupertino,
};

String filterLabel(ChildrenFilter filter) => switch (filter) {
  ChildrenFilter.all => AppStrings.filterAll,
  ChildrenFilter.arrivedToday => AppStrings.filterArrived,
};

String scopeLabel(ScheduleScope scope) => switch (scope) {
  ScheduleScope.today => AppStrings.scopeToday,
  ScheduleScope.week => AppStrings.scopeWeek,
};

String scheduleGroupTitle(ScheduleGroup group) => switch (group) {
  ScheduleGroup.morning => 'Ertalab',
  ScheduleGroup.midday => 'Kunduzi',
  ScheduleGroup.evening => 'Kechqurun',
  ScheduleGroup.monday => 'Dushanba',
  ScheduleGroup.tuesday => 'Seshanba',
  ScheduleGroup.wednesday => 'Chorshanba',
  ScheduleGroup.thursday => 'Payshanba',
  ScheduleGroup.friday => 'Juma',
};

String arrivalLabel(bool arrivedToday) =>
    arrivedToday ? 'Bugun keldi' : 'Bugun kelmadi';

String fontScaleLabel(double value) => '${(value * 100).round()}%';
