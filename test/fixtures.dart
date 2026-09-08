import 'package:adaptive_ui_lab/data/models/app_settings.dart';
import 'package:adaptive_ui_lab/data/models/child.dart';
import 'package:adaptive_ui_lab/data/models/schedule_item.dart';

final Child amina = Child(
  id: 'c1',
  name: 'Amina Karimova',
  kindergarten: 'Kamalak bogʻchasi',
  groupName: 'Quyoshcha guruhi',
  avatar: 'A',
  attendedDays: 18,
  totalDays: 20,
  arrivedToday: true,
  birthDate: DateTime(2020, 3, 14),
);

final Child bekzod = Child(
  id: 'c2',
  name: 'Bekzod Toshmatov',
  kindergarten: 'Kamalak bogʻchasi',
  groupName: 'Yulduzcha guruhi',
  avatar: 'B',
  attendedDays: 12,
  totalDays: 20,
  arrivedToday: false,
  birthDate: DateTime(2019, 11, 2),
);

final Child dilnoza = Child(
  id: 'c3',
  name: 'Dilnoza Rasulova',
  kindergarten: 'Bolajon bogʻchasi',
  groupName: 'Kapalak guruhi',
  avatar: 'D',
  attendedDays: 20,
  totalDays: 20,
  arrivedToday: true,
  birthDate: DateTime(2020, 7, 30),
);

final List<Child> testChildren = [amina, bekzod, dilnoza];

const List<ScheduleItem> testToday = [
  ScheduleItem(
    id: 't1',
    title: 'Ertalabki nonushta',
    subtitle: 'Sutli boʻtqa',
    hour: 8,
    minute: 30,
    group: ScheduleGroup.morning,
    scope: ScheduleScope.today,
    done: true,
  ),
  ScheduleItem(
    id: 't2',
    title: 'Tushlik',
    subtitle: 'Mastava',
    hour: 12,
    minute: 0,
    group: ScheduleGroup.midday,
    scope: ScheduleScope.today,
    done: false,
  ),
];

const List<ScheduleItem> testWeek = [
  ScheduleItem(
    id: 'w1',
    title: 'Musiqa darsi',
    subtitle: 'Katta zal',
    hour: 10,
    minute: 0,
    group: ScheduleGroup.monday,
    scope: ScheduleScope.week,
    done: false,
  ),
];

final AppSettings testSettings = AppSettings.defaults();
