
import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class MyAlarm {
  static List<MyAlarmSettings> restoreAlarms() {
    final exAlarms = <MyAlarmSettings>[];
    final alarms = Alarm.getAlarms();

    for(final alarm in alarms) {
      exAlarms.add(MyAlarmSettings(settings: alarm, extensionSettings: AlarmExtensionSettings(id: alarm.id)));
    }

    return exAlarms;
  }

  static Future<void> init({bool showDebugLogs = true}) async {
    await Alarm.init(showDebugLogs: showDebugLogs);
    await AlarmExtensionSettings.init();
  }

  static StreamSubscription<AlarmSettings>? onInitState(void Function(AlarmSettings) onData) {
    if(Alarm.android ) {
      checkAndroidNotificationPermission();
    }
    
    return Alarm.ringStream.stream.listen(onData);
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
  final AlarmSettings settings;
  final AlarmExtensionSettings extensionSettings;

  MyAlarmSettings({
    required this.settings,
    required this.extensionSettings,
  });
}