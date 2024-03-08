import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmActionBottomSheetDone {
  final AlarmAction action;
  final int taskRepeat;
  final Difficulty difficulty;

  AlarmActionBottomSheetDone(
      {required this.action,
      required this.taskRepeat,
      required this.difficulty});
}

class AlarmActionBottomSheet extends StatefulWidget {
  final MyAlarmSettings? alarmSettings;

  const AlarmActionBottomSheet({super.key, this.alarmSettings});

  @override
  State<AlarmActionBottomSheet> createState() => _AlarmActionBottomSheetState();
}

class _AlarmActionBottomSheetState extends State<AlarmActionBottomSheet> {
  late bool _creating;
  late AlarmAction _action;
  late int _taskRepeat;
  late Difficulty _difficulty;

  @override
  void initState() {
    super.initState();

    _creating = widget.alarmSettings == null;
    if (!_creating) {
      _action = widget.alarmSettings!.extensionSettings.action;
      _taskRepeat = widget.alarmSettings!.extensionSettings.taskRepeat;
      _difficulty = widget.alarmSettings!.extensionSettings.difficulty;
    } else {
      _action = AlarmAction.math;
      _taskRepeat = 1;
      _difficulty = Difficulty.normal;
    }
  }

  void saveAction(BuildContext context) {
    Navigator.pop(
      context,
      AlarmActionBottomSheetDone(
        action: _action,
        taskRepeat: _taskRepeat,
        difficulty: _difficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text("ALARM ACTION BOTTOMSHEET"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Action",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: _action,
                items: const [
                  DropdownMenuItem<AlarmAction>(
                    value: AlarmAction.math,
                    child: Text('Math'),
                  ),
                  DropdownMenuItem<AlarmAction>(
                    value: AlarmAction.smile,
                    child: Text('Smile'),
                  ),
                  DropdownMenuItem<AlarmAction>(
                    value: AlarmAction.audio,
                    child: Text('Audio'),
                  ),
                ],
                onChanged: (value) => setState(() => _action = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Repeat",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: _taskRepeat,
                items: const [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('1'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('2'),
                  ),
                  DropdownMenuItem<int>(
                    value: 3,
                    child: Text('3'),
                  ),
                ],
                onChanged: (value) => setState(() => _taskRepeat = value!),
              ),
              Text(
                "Difficulty",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: _difficulty,
                items: const [
                  DropdownMenuItem<Difficulty>(
                    value: Difficulty.veryEasy,
                    child: Text('VERY EASY'),
                  ),
                  DropdownMenuItem<Difficulty>(
                    value: Difficulty.easy,
                    child: Text('EASY'),
                  ),
                  DropdownMenuItem<Difficulty>(
                    value: Difficulty.normal,
                    child: Text('NORMAL'),
                  ),
                  DropdownMenuItem<Difficulty>(
                    value: Difficulty.hard,
                    child: Text('HARD'),
                  ),
                  DropdownMenuItem<Difficulty>(
                    value: Difficulty.veryHard,
                    child: Text('VERY HARD'),
                  ),
                ],
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => saveAction(context),
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
