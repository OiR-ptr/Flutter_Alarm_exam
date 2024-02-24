import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class MyAlarm {
  static List<MyAlarmSettings> restoreAlarms() {
    final myAlarms = <MyAlarmSettings>[];
    final alarms = Alarm.getAlarms();
    final exAlarms = AlarmExpandConfigStorage.getSavedConfig();

    for (final alarm in alarms) {
      myAlarms.add(MyAlarmSettings(
          id: alarm.id,
          settings: alarm,
          extensionSettings: exAlarms.firstWhere((element) => element.id == alarm.id)));
    }

    return myAlarms;
  }

  static Future<void> init({bool showDebugLogs = true}) async {
    await Alarm.init(showDebugLogs: showDebugLogs);
    await AlarmExtensionSettings.init();
  }

  static Future<bool> stop(int id) async {
    await AlarmExpandConfigStorage.removeConfig(id);
    return await Alarm.stop(id);
  }

  static Future<void> stopAll() async {
    await AlarmExpandConfigStorage.removeConfigAll();
    await Alarm.stopAll();
  }

  static StreamSubscription<AlarmSettings>? onInitState(
      void Function(AlarmSettings) onData) {
    if (Alarm.android) {
      checkAndroidNotificationPermission();
    }

    return Alarm.ringStream.stream.listen(onData);
  }

  static Future<bool> set(
      {required MyAlarmSettings settings}) async {
    if(await Alarm.set(alarmSettings: settings.settings)) {
      AlarmExpandConfigStorage.saveConfig(settings.extensionSettings);
      return true;
    }

    return false;
  }

  static Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  static Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      alarmPrint('Requesting external storage permission...');
      final res = await Permission.storage.request();
      alarmPrint(
        'External storage permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }
}

class MyAlarmSettings {
  final int id;
  final AlarmSettings settings;
  final AlarmExtensionSettings extensionSettings;

  MyAlarmSettings({
    required this.id,
    required this.settings,
    required this.extensionSettings,
  });
}