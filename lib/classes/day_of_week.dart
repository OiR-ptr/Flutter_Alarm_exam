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
    switch (this) {
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
      case DayOfWeek.sunday:
        return 7;
    }
  }

  static DayOfWeek fromValue(int value) {
    return DayOfWeek.values.firstWhere((type) => type.value == value,
        orElse: () => throw ArgumentError('Invalid day value'));
  }

  static Duration getHowManyDays(DayOfWeek next, DateTime? basisAt) {
    basisAt ??= DateTime.now();
    return basisAt.weekday < next.value
        ? Duration(days: next.value - basisAt.weekday)
        : Duration(days: 7 + next.value - basisAt.weekday);
  }

  static DayOfWeek getNearWeekday(Iterable<DayOfWeek> candidates, DateTime? basisAt) {
    basisAt ??= DateTime.now();

    // TODO: 指定日から最も近い曜日を返す
    return DayOfWeek.friday;
  }

  static DateTime getNextDayOfWeek(DayOfWeek next, DateTime? basisAt) {
    basisAt ??= DateTime.now();

    return DateTime(
      basisAt.year,
      basisAt.month,
      basisAt.day,
      0,
      0,
      0,
      0,
    ).add(getHowManyDays(next, basisAt));
  }
}