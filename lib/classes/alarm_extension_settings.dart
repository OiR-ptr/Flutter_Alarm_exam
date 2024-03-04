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

class AlarmExtensionSettings {
  final int id;
  final AlarmAction action;

  AlarmExtensionSettings({required this.id, required this.action});

  AlarmExtensionSettings copyWith({
    int? id,
    AlarmAction? action,
  }) {
    return AlarmExtensionSettings(
      id: id ?? this.id,
      action: action ?? this.action,
    );
  }

  factory AlarmExtensionSettings.fromJson(Map<String, dynamic> json) =>
      AlarmExtensionSettings(
          id: json['id'] as int, action: parseAction(json['action']));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
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
