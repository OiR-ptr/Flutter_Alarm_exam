import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class MathRingScreen extends StatelessWidget {
  final MyAlarmSettings alarmSettings;
  const MathRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  Future<void> stopAlarm(BuildContext context) async {
    if(!context.mounted) return;

    await MyAlarm.stop(alarmSettings.id);
    if(context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
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
