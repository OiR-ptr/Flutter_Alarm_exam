import 'package:alarming/classes/day_of_week.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmPeriodicBottomSheetDone {
  final List<DayOfWeek> rings;

  AlarmPeriodicBottomSheetDone({required this.rings});
}

class AlarmPeriodicBottomSheet extends StatefulWidget {
  final MyAlarmSettings? alarmSettings;

  const AlarmPeriodicBottomSheet({super.key, required this.alarmSettings});

  @override
  State<AlarmPeriodicBottomSheet> createState() =>
      _AlarmPeriodicBottomSheetState();
}

class _AlarmPeriodicBottomSheetState extends State<AlarmPeriodicBottomSheet> {
  late bool _creating;
  final Map<DayOfWeek, bool> _ringsDayOfWeek = {
    DayOfWeek.monday: false,
    DayOfWeek.tuesday: false,
    DayOfWeek.wednesday: false,
    DayOfWeek.thursday: false,
    DayOfWeek.friday: false,
    DayOfWeek.saturday: false,
    DayOfWeek.sunday: false,
  };

  @override
  void initState() {
    super.initState();

    _creating = widget.alarmSettings == null;
    if(!_creating) {
      widget.alarmSettings?.extensionSettings.ringsDayOfWeek.forEach((element) {
        _ringsDayOfWeek[element] = true;
      });
    }
  }

  void savePeriodicSetting(BuildContext context) {
    var availables = _ringsDayOfWeek.entries
        .where((entry) {
          return entry.value;
        })
        .map((e) => e.key)
        .toList();

    Navigator.pop(
      context,
      AlarmPeriodicBottomSheetDone(
        rings: availables,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> checkboxies = [];
    for (var weekday in DayOfWeek.values) {
      checkboxies.add(Row(
        children: [
          Checkbox(
            value: _ringsDayOfWeek[weekday],
            onChanged: (value) => setState(() {
              _ringsDayOfWeek[weekday] = !_ringsDayOfWeek[weekday]!;
            }),
          ),
          TextButton(
            onPressed: () => setState(() {
              _ringsDayOfWeek[weekday] = !_ringsDayOfWeek[weekday]!;
            }),
            child: Text(weekday.name),
          ),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListView(
            shrinkWrap: true,
            children: checkboxies,
          ),
          const Spacer(),
          TextButton(
            onPressed: () => savePeriodicSetting(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("完了"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
