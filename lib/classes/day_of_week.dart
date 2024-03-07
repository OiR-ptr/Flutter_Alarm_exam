enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekExtension on DayOfWeek {
  int get value {
    switch(this) {
      case DayOfWeek.monday:    return 1;
      case DayOfWeek.tuesday:   return 2;
      case DayOfWeek.wednesday: return 3;
      case DayOfWeek.thursday:  return 4;
      case DayOfWeek.friday:    return 5;
      case DayOfWeek.saturday:  return 6;
      case DayOfWeek.sunday:    return 7;
    }
  }

  static DayOfWeek fromValue(int value) {
    return DayOfWeek.values.firstWhere((type) => type.value == value, orElse: () => throw ArgumentError('Invalid day value'));
  }
}