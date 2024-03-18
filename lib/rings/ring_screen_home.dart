import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/rings/audio_detection_ring_screen.dart';
import 'package:alarming/rings/math_ring_screen.dart';
import 'package:alarming/rings/smile_detection_ring_screen.dart';
import 'package:flutter/material.dart';

class RingScreenHome extends StatelessWidget {
  final MyAlarmSettings alarmSettings;

  const RingScreenHome({Key? key, required this.alarmSettings})
      : super(key: key);

  void snoozeAlarm(BuildContext context, Duration snoozeAfter) {
    MyAlarm.snooze(
      settings: alarmSettings,
      duration: snoozeAfter,
    ).then((_) => Navigator.pop(context));
  }

  Future<void> gotoStopActionPage(BuildContext context) async {
    MyAlarm.snooze(
      settings: alarmSettings,
      duration: const Duration(minutes: 1),
    ).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // アクション設定に従って分岐
            switch (alarmSettings.extensionSettings.action) {
              case AlarmAction.math:
                return MathRingScreen(
                  alarmSettings: alarmSettings,
                );
              case AlarmAction.smile:
                return SmileDetectionRingScreen(
                  alarmSettings: alarmSettings,
                );
              case AlarmAction.audio:
                return const RecordToStreamExample();
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                        snoozeAlarm(context, const Duration(minutes: 5)),
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
      ),
    );
  }
}
