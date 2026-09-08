import 'package:equatable/equatable.dart';

class Child extends Equatable {
  const Child({
    required this.id,
    required this.name,
    required this.kindergarten,
    required this.groupName,
    required this.avatar,
    required this.attendedDays,
    required this.totalDays,
    required this.arrivedToday,
    required this.birthDate,
  });

  final String id;
  final String name;
  final String kindergarten;
  final String groupName;
  final String avatar;
  final int attendedDays;
  final int totalDays;
  final bool arrivedToday;
  final DateTime birthDate;

  double get attendanceRate => totalDays == 0 ? 0 : attendedDays / totalDays;

  int get missedDays => totalDays - attendedDays;

  Child copyWith({bool? arrivedToday, int? attendedDays}) {
    return Child(
      id: id,
      name: name,
      kindergarten: kindergarten,
      groupName: groupName,
      avatar: avatar,
      attendedDays: attendedDays ?? this.attendedDays,
      totalDays: totalDays,
      arrivedToday: arrivedToday ?? this.arrivedToday,
      birthDate: birthDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    kindergarten,
    groupName,
    avatar,
    attendedDays,
    totalDays,
    arrivedToday,
    birthDate,
  ];
}
