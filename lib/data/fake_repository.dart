import 'dart:math';

import 'models/app_settings.dart';
import 'models/child.dart';
import 'models/schedule_item.dart';

class RepositoryFailure implements Exception {
  const RepositoryFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class FakeRepository {
  FakeRepository({Random? random, this.artificialDelay = true})
    : _random = random ?? Random(7);

  final Random _random;
  final bool artificialDelay;

  bool failNextLoad = false;

  final List<Child> _children = <Child>[
    Child(
      id: 'c1',
      name: 'Amina Karimova',
      kindergarten: 'Kamalak bogʻchasi',
      groupName: 'Quyoshcha guruhi',
      avatar: '🐣',
      attendedDays: 18,
      totalDays: 20,
      arrivedToday: true,
      birthDate: DateTime(2020, 3, 14),
    ),
    Child(
      id: 'c2',
      name: 'Bekzod Toshmatov',
      kindergarten: 'Kamalak bogʻchasi',
      groupName: 'Yulduzcha guruhi',
      avatar: '🚀',
      attendedDays: 12,
      totalDays: 20,
      arrivedToday: false,
      birthDate: DateTime(2019, 11, 2),
    ),
    Child(
      id: 'c3',
      name: 'Dilnoza Rasulova',
      kindergarten: 'Bolajon bogʻchasi',
      groupName: 'Kapalak guruhi',
      avatar: '🦋',
      attendedDays: 20,
      totalDays: 20,
      arrivedToday: true,
      birthDate: DateTime(2020, 7, 30),
    ),
    Child(
      id: 'c4',
      name: 'Eldor Nazarov',
      kindergarten: 'Bolajon bogʻchasi',
      groupName: 'Chinnigul guruhi',
      avatar: '🐼',
      attendedDays: 9,
      totalDays: 20,
      arrivedToday: false,
      birthDate: DateTime(2021, 1, 9),
    ),
    Child(
      id: 'c5',
      name: 'Farrux Yoʻldoshev',
      kindergarten: 'Umid bogʻchasi',
      groupName: 'Quyoshcha guruhi',
      avatar: '⚽️',
      attendedDays: 16,
      totalDays: 20,
      arrivedToday: true,
      birthDate: DateTime(2019, 6, 21),
    ),
    Child(
      id: 'c6',
      name: 'Gulnora Sobirova',
      kindergarten: 'Umid bogʻchasi',
      groupName: 'Kapalak guruhi',
      avatar: '🌸',
      attendedDays: 14,
      totalDays: 20,
      arrivedToday: false,
      birthDate: DateTime(2020, 9, 5),
    ),
    Child(
      id: 'c7',
      name: 'Humoyun Alimov',
      kindergarten: 'Kamalak bogʻchasi',
      groupName: 'Yulduzcha guruhi',
      avatar: '🐧',
      attendedDays: 19,
      totalDays: 20,
      arrivedToday: true,
      birthDate: DateTime(2021, 2, 27),
    ),
    Child(
      id: 'c8',
      name: 'Iroda Qodirova',
      kindergarten: 'Bolajon bogʻchasi',
      groupName: 'Chinnigul guruhi',
      avatar: '🎨',
      attendedDays: 11,
      totalDays: 20,
      arrivedToday: false,
      birthDate: DateTime(2020, 12, 12),
    ),
  ];

  static const List<ScheduleItem> _today = <ScheduleItem>[
    ScheduleItem(
      id: 't1',
      title: 'Qabul va ertalabki koʻrik',
      subtitle: 'Tibbiyot xodimi',
      hour: 7,
      minute: 30,
      group: ScheduleGroup.morning,
      scope: ScheduleScope.today,
      done: true,
    ),
    ScheduleItem(
      id: 't2',
      title: 'Ertalabki nonushta',
      subtitle: 'Sutli boʻtqa, choy',
      hour: 8,
      minute: 30,
      group: ScheduleGroup.morning,
      scope: ScheduleScope.today,
      done: true,
    ),
    ScheduleItem(
      id: 't3',
      title: 'Rivojlantiruvchi mashgʻulot',
      subtitle: 'Nutq va matematika',
      hour: 9,
      minute: 45,
      group: ScheduleGroup.morning,
      scope: ScheduleScope.today,
      done: false,
    ),
    ScheduleItem(
      id: 't4',
      title: 'Tushlik',
      subtitle: 'Mastava, non',
      hour: 12,
      minute: 0,
      group: ScheduleGroup.midday,
      scope: ScheduleScope.today,
      done: false,
    ),
    ScheduleItem(
      id: 't5',
      title: 'Kunduzgi uyqu',
      subtitle: 'Yotoqxona',
      hour: 13,
      minute: 15,
      group: ScheduleGroup.midday,
      scope: ScheduleScope.today,
      done: false,
    ),
    ScheduleItem(
      id: 't6',
      title: 'Ijodiy mashgʻulot',
      subtitle: 'Rasm va applikatsiya',
      hour: 15,
      minute: 30,
      group: ScheduleGroup.evening,
      scope: ScheduleScope.today,
      done: false,
    ),
    ScheduleItem(
      id: 't7',
      title: 'Ota-onalarga topshirish',
      subtitle: 'Asosiy kirish',
      hour: 17,
      minute: 45,
      group: ScheduleGroup.evening,
      scope: ScheduleScope.today,
      done: false,
    ),
  ];

  static const List<ScheduleItem> _week = <ScheduleItem>[
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
    ScheduleItem(
      id: 'w2',
      title: 'Jismoniy tarbiya',
      subtitle: 'Hovli maydonchasi',
      hour: 11,
      minute: 0,
      group: ScheduleGroup.monday,
      scope: ScheduleScope.week,
      done: false,
    ),
    ScheduleItem(
      id: 'w3',
      title: 'Ingliz tili',
      subtitle: 'Kichik xona',
      hour: 9,
      minute: 30,
      group: ScheduleGroup.tuesday,
      scope: ScheduleScope.week,
      done: false,
    ),
    ScheduleItem(
      id: 'w4',
      title: 'Tabiat bilan tanishuv',
      subtitle: 'Bogʻ sayri',
      hour: 10,
      minute: 45,
      group: ScheduleGroup.wednesday,
      scope: ScheduleScope.week,
      done: false,
    ),
    ScheduleItem(
      id: 'w5',
      title: 'Ota-onalar yigʻilishi',
      subtitle: 'Yigʻilish zali',
      hour: 18,
      minute: 0,
      group: ScheduleGroup.thursday,
      scope: ScheduleScope.week,
      done: false,
    ),
    ScheduleItem(
      id: 'w6',
      title: 'Ertaklar bayrami',
      subtitle: 'Sahna koʻrinishi',
      hour: 16,
      minute: 0,
      group: ScheduleGroup.friday,
      scope: ScheduleScope.week,
      done: false,
    ),
  ];

  AppSettings _settings = AppSettings.defaults();

  Future<void> _delay() async {
    if (!artificialDelay) return;
    await Future<void>.delayed(
      Duration(milliseconds: 300 + _random.nextInt(500)),
    );
  }

  Future<List<Child>> fetchChildren() async {
    await _delay();
    if (failNextLoad) {
      failNextLoad = false;
      throw const RepositoryFailure(
        'Serverga ulanib boʻlmadi. Internetni tekshiring.',
      );
    }
    return List<Child>.unmodifiable(_children);
  }

  Future<List<ScheduleItem>> fetchSchedule(ScheduleScope scope) async {
    await _delay();
    if (failNextLoad) {
      failNextLoad = false;
      throw const RepositoryFailure('Kun tartibini yuklab boʻlmadi.');
    }
    return scope == ScheduleScope.today ? _today : _week;
  }

  Future<void> deleteChild(String id) async {
    await _delay();
    _children.removeWhere((child) => child.id == id);
  }

  Future<void> restoreChild(Child child, int index) async {
    await _delay();
    _children.insert(index.clamp(0, _children.length), child);
  }

  Future<AppSettings> loadSettings() async {
    await _delay();
    return _settings;
  }

  Future<AppSettings> saveSettings(AppSettings settings) async {
    _settings = settings;
    return _settings;
  }

  Future<AppSettings> clearSettings() async {
    await _delay();
    _settings = AppSettings.defaults();
    return _settings;
  }
}
