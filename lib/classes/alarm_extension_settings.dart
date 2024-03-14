import 'dart:convert';

import 'package:alarming/classes/day_of_week.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AlarmAction {
  math,
  smile,
  audio,
}

AlarmAction parseAction(String actionName) {
  switch (actionName) {
    case "math":      return AlarmAction.math;
    case "smile":     return AlarmAction.smile;
    case "audio":     return AlarmAction.audio;
  }

  return AlarmAction.math;
}

enum Difficulty {
  veryEasy,
  easy,
  normal,
  hard,
  veryHard,
}

Difficulty parseDifficulty(String difficultyName) {
  switch(difficultyName) {
    case "veryEasy":  return Difficulty.veryEasy;
    case "easy":      return Difficulty.easy;
    case "normal":    return Difficulty.normal;
    case "hard":      return Difficulty.hard;
    case "veryHard":  return Difficulty.veryHard;
  }

  return Difficulty.normal;
}

class AlarmExtensionSettings {
  final int id;
  final AlarmAction action;
  final int taskRepeat;
  final Difficulty difficulty;
  final Iterable<DayOfWeek> ringsDayOfWeek;
  final Duration alarmAt;
  final bool isSnooze;

  AlarmExtensionSettings({
    required this.id,
    required this.action,
    required this.taskRepeat,
    required this.difficulty,
    required this.ringsDayOfWeek,
    required this.alarmAt,
    required this.isSnooze,
  });

  bool isPeriodic() {
    return ringsDayOfWeek.isNotEmpty;
  }

  AlarmExtensionSettings copyWith({
    int? id,
    AlarmAction? action,
    int? taskRepeat,
    Difficulty? difficulty,
    Iterable<DayOfWeek>? ringsDayOfWeek,
    Duration? alarmAt,
    bool? isSnooze,
  }) {
    return AlarmExtensionSettings(
      id: id ?? this.id,
      action: action ?? this.action,
      taskRepeat: taskRepeat ?? this.taskRepeat,
      difficulty: difficulty ?? this.difficulty,
      ringsDayOfWeek: ringsDayOfWeek ?? this.ringsDayOfWeek,
      alarmAt: alarmAt ?? this.alarmAt,
      isSnooze: isSnooze ?? this.isSnooze,
    );
  }

  factory AlarmExtensionSettings.fromJson(Map<String, dynamic> json) =>
      AlarmExtensionSettings(
        id: json['id'] as int,
        action: parseAction(json['action']),
        taskRepeat: json['taskRepeat'] as int,
        difficulty: parseDifficulty(json['difficulty']),
        ringsDayOfWeek: [
          json["_rings_on_mon"] ? DayOfWeek.monday : null,
          json["_rings_on_tue"] ? DayOfWeek.tuesday : null,
          json["_rings_on_wed"] ? DayOfWeek.wednesday : null,
          json["_rings_on_thu"] ? DayOfWeek.thursday : null,
          json["_rings_on_fri"] ? DayOfWeek.friday : null,
          json["_rings_on_sat"] ? DayOfWeek.saturday : null,
          json["_rings_on_sun"] ? DayOfWeek.sunday : null,
        ].where((element) => element != null).map((e) => e!),
        alarmAt: Duration(
          minutes: json["_alarm_inminutes"] as int,
        ),
        isSnooze: json["isSnooze"] as bool,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'taskRepeat': taskRepeat,
      'difficulty': difficulty.name,
      '_rings_on_mon': ringsDayOfWeek.contains(DayOfWeek.monday),
      '_rings_on_tue': ringsDayOfWeek.contains(DayOfWeek.tuesday),
      '_rings_on_wed': ringsDayOfWeek.contains(DayOfWeek.wednesday),
      '_rings_on_thu': ringsDayOfWeek.contains(DayOfWeek.thursday),
      '_rings_on_fri': ringsDayOfWeek.contains(DayOfWeek.friday),
      '_rings_on_sat': ringsDayOfWeek.contains(DayOfWeek.saturday),
      '_rings_on_sun': ringsDayOfWeek.contains(DayOfWeek.sunday),
      '_alarm_inminutes': alarmAt.inMinutes,
      'isSnooze': isSnooze,
    };
  }

  static Future<void> init() async {
    await AlarmExpandConfigStorage.init();
  }
}

class AlarmExpandConfigStorage {
  static const prefix = '__alarm_expand__';

  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveConfig(AlarmExtensionSettings config) =>
      prefs.setString('$prefix${config.id}', jsonEncode(config));

  static Future<void> removeConfig(int id) => prefs.remove("$prefix$id");

  static Future<void> removeConfigAll() async {
    await prefs.clear();
  }

  static List<AlarmExtensionSettings> getSavedConfig() {
    final configs = <AlarmExtensionSettings>[];
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final res = prefs.getString(key);
        configs.add(AlarmExtensionSettings.fromJson(jsonDecode(res!)));
      }
    }

    return configs;
  }
}
