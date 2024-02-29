import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class MathRingScreen extends StatelessWidget {
  final MyAlarmSettings alarmSettings;
  const MathRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  void stopAlarm(BuildContext context) {
    MyAlarm.stop(alarmSettings.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("test"),
            ElevatedButton(
              onPressed: () {
                stopAlarm(context);
              },
              child: const Text("STOP"),
            ),
          ],
        ),
      ),
    );
  }
}
