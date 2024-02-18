import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AlarmExpandConfig {
  final int id;

  AlarmExpandConfig({required this.id});

  factory AlarmExpandConfig.fromJson(Map<String, dynamic> json) =>
      AlarmExpandConfig(id: json['id'] as int);

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}

class AlarmExpandConfigStorage {
  static const prefix = '__alarm_expand__';

  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveConfig(AlarmExpandConfig config) =>
      prefs.setString('$prefix${config.id}', jsonEncode(config));

  static List<AlarmExpandConfig> getSavedConfig() {
    final configs = <AlarmExpandConfig>[];
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final res = prefs.getString(key);
        configs.add(AlarmExpandConfig.fromJson(jsonDecode(res!)));
      }
    }

    return configs;
  }
}
