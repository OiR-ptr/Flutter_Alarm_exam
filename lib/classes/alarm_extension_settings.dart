import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum AlarmAction {
  math,
}

AlarmAction parseAction(String actionName) {
  switch (actionName) {
    case "math":
      return AlarmAction.math;
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

  AlarmExtensionSettings({
    required this.id,
    required this.action,
    required this.taskRepeat,
    required this.difficulty,
  });

  AlarmExtensionSettings copyWith({
    int? id,
    AlarmAction? action,
    int? taskRepeat,
    Difficulty? difficulty,
  }) {
    return AlarmExtensionSettings(
      id: id ?? this.id,
      action: action ?? this.action,
      taskRepeat: taskRepeat ?? this.taskRepeat,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  factory AlarmExtensionSettings.fromJson(Map<String, dynamic> json) =>
      AlarmExtensionSettings(
        id: json['id'] as int,
        action: parseAction(json['action']),
        taskRepeat: json['taskRepeat'] as int,
        difficulty: parseDifficulty(json['difficulty']),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'taskRepeat': taskRepeat,
      'difficulty': difficulty.name,
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
