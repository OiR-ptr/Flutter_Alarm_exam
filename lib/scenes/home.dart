import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/scenes/edit_alarm.dart';
import 'package:alarming/scenes/ring.dart';
import 'package:alarming/scenes/shortcut_button.dart';
import 'package:alarming/widgets/tile.dart';
import 'package:flutter/material.dart';

class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({Key? key}) : super(key: key);

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
}

class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
  late List<MyAlarmSettings> alarms;

  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    subscription ??= MyAlarm.onInitState(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
    loadAlarms();
  }

  void loadAlarms() {
    setState(() {
      alarms = MyAlarm.restoreAlarms();
      alarms.sort(
          (a, b) => a.settings.dateTime.isBefore(b.settings.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExampleAlarmRingScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: ExampleAlarmEditScreen(alarmSettings: settings),
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
                  return ExampleAlarmTile(
                    key: Key(alarms[index].settings.id.toString()),
                    title: TimeOfDay(
                      hour: alarms[index].settings.dateTime.hour,
                      minute: alarms[index].settings.dateTime.minute,
                    ).format(context),
                    onPressed: () => navigateToAlarmScreen(alarms[index].settings),
                    onDismissed: () {
                      Alarm.stop(alarms[index].settings.id).then((_) => loadAlarms());
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
            ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
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
