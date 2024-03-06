import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/scenes/edit_alarm_screen.dart';
import 'package:alarming/rings/ring_screen_home.dart';
import 'package:alarming/scenes/shortcut_button.dart';
import 'package:alarming/widgets/tile.dart';
import 'package:flutter/material.dart';

class AlarmHomeScreen extends StatefulWidget {
  const AlarmHomeScreen({Key? key}) : super(key: key);

  @override
  State<AlarmHomeScreen> createState() => _AlarmHomeScreenState();
}

class _AlarmHomeScreenState extends State<AlarmHomeScreen> {
  late List<MyAlarmSettings> alarms;

  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    subscription ??= MyAlarm.onInitState((alarmSettings) {
      navigateToRingScreen(
        alarms.firstWhere((alarm) => alarm.id == alarmSettings.id),
      );
    });
    // MyAlarm.stopAll(); // 開発時にshared:preferenceを吹っ飛ばすために追加している
    loadAlarms();
  }

  void loadAlarms() {
    setState(() {
      alarms = MyAlarm.restoreAlarms();
      alarms.sort(
          (a, b) => a.settings.dateTime.isBefore(b.settings.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(MyAlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RingScreenHome(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(MyAlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: AlarmEditScreen(alarmSettings: settings),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('alarming')),
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.separated(
                itemCount: alarms.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return AlarmTile(
                    key: Key(alarms[index].settings.id.toString()),
                    title: TimeOfDay(
                      hour: alarms[index].settings.dateTime.hour,
                      minute: alarms[index].settings.dateTime.minute,
                    ).format(context),
                    onPressed: () => navigateToAlarmScreen(alarms[index]),
                    onDismissed: () {
                      MyAlarm.stop(alarms[index].id).then((_) => loadAlarms());
                    },
                  );
                },
              )
            : Center(
                child: Text(
                  "No alarms set",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AlarmShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
