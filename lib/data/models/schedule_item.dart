import 'package:equatable/equatable.dart';

enum ScheduleScope { today, week }

enum ScheduleGroup {
  morning,
  midday,
  evening,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

class ScheduleItem extends Equatable {
  const ScheduleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hour,
    required this.minute,
    required this.group,
    required this.scope,
    required this.done,
  });

  final String id;
  final String title;
  final String subtitle;
  final int hour;
  final int minute;
  final ScheduleGroup group;
  final ScheduleScope scope;
  final bool done;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    hour,
    minute,
    group,
    scope,
    done,
  ];
}
