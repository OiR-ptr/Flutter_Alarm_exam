import 'package:alarm/alarm.dart';
import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmShortcutButton extends StatefulWidget {
  final void Function() refreshAlarms;

  const AlarmShortcutButton({Key? key, required this.refreshAlarms})
      : super(key: key);

  @override
  State<AlarmShortcutButton> createState() => _AlarmShortcutButtonState();
}

class _AlarmShortcutButtonState extends State<AlarmShortcutButton> {
  bool showMenu = false;

  Future<void> onPressButton(int delayInHours) async {
    DateTime dateTime = DateTime.now().add(Duration(hours: delayInHours));
    double volume = 0.5;

    if (delayInHours != 0) {
      dateTime = dateTime.copyWith(second: 0, millisecond: 0);
    }

    setState(() => showMenu = false);

    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: 'assets/marimba.mp3',
      volume: volume,
      notificationTitle: 'Alarm example',
      notificationBody:
          'Shortcut button alarm with delay of $delayInHours hours',
    );

    await MyAlarm.set(
      settings: MyAlarmSettings(
        id: id,
        settings: alarmSettings,
        extensionSettings: AlarmExtensionSettings(
          id: id,
          action: AlarmAction.math,
          taskRepeat: 1,
          difficulty: Difficulty.normal,
          ringsDayOfWeek: [],
          alarmAt: Duration(
            hours: dateTime.hour,
            minutes: dateTime.minute,
          ),
        ),
      ),
    );

    widget.refreshAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: () {
            setState(() => showMenu = true);
          },
          child: FloatingActionButton(
            onPressed: () => onPressButton(0),
            backgroundColor: Colors.red,
            heroTag: null,
            child: const Text("RING NOW", textAlign: TextAlign.center),
          ),
        ),
        if (showMenu)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => onPressButton(24),
                child: const Text("+24h"),
              ),
              TextButton(
                onPressed: () => onPressButton(36),
                child: const Text("+36h"),
              ),
              TextButton(
                onPressed: () => onPressButton(48),
                child: const Text("+48h"),
              ),
            ],
          ),
      ],
    );
  }
}
