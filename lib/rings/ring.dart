import 'package:alarming/classes/my_alarm_settings.dart';
// import 'package:alarming/rings/face_detection.dart';
import 'package:alarming/rings/math.dart';
import 'package:flutter/material.dart';

class ExampleAlarmRingScreen extends StatelessWidget {
  final MyAlarmSettings alarmSettings;

  const ExampleAlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  void snoozeAlarm(BuildContext context, Duration snoozeAfter) {
    final now = DateTime.now();
    MyAlarm.set(
      settings: alarmSettings.copyWith(
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          0,
          0,
        ).add(snoozeAfter),
      ),
    ).then((_) => Navigator.pop(context));
  }

  Future<void> gotoStopActionPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MathRingScreen(
          alarmSettings: alarmSettings,
          questions: "192 + 256 + 1 = ?",
        ),
      ),
    );
    // if (!context.mounted) return;
    // await MyAlarm.stop(alarmSettings.id);

    // if (context.mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const FaceDetectionRingScreen(),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "You alarm (${alarmSettings.id}) is ringing...",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () =>
                      snoozeAlarm(context, const Duration(minutes: 1)),
                  child: Text(
                    "Snooze",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () => gotoStopActionPage(context),
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
