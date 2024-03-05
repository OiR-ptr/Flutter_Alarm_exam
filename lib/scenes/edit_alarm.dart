import 'package:alarm/alarm.dart';
import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  final MyAlarmSettings? alarmSettings;

  const ExampleAlarmEditScreen({Key? key, this.alarmSettings})
      : super(key: key);

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late double? volume;
  late String assetAudio;
  late AlarmAction action;
  late int taskRepeat;
  late Difficulty difficulty;

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      volume = null;
      assetAudio = 'assets/marimba.mp3';
      action = AlarmAction.math;
      taskRepeat = 1;
      difficulty = Difficulty.normal;
    } else {
      selectedDateTime = widget.alarmSettings!.settings.dateTime;
      volume = widget.alarmSettings!.settings.volume;
      assetAudio = widget.alarmSettings!.settings.assetAudioPath;
      action = widget.alarmSettings!.extensionSettings.action;
      taskRepeat = widget.alarmSettings!.extensionSettings.taskRepeat;
      difficulty = widget.alarmSettings!.extensionSettings.difficulty;
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final DateTime now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  MyAlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: true,
      vibrate: true,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: 'Alarm example',
      notificationBody: 'Your alarm ($id) is ringing',
    );
    final exSettings = AlarmExtensionSettings(
      id: id,
      action: action,
      taskRepeat: taskRepeat,
      difficulty: difficulty,
    );
    return MyAlarmSettings(
        id: id, settings: alarmSettings, extensionSettings: exSettings);
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);

    MyAlarm.set(settings: buildAlarmSettings()).then((res) {
      if (res) Navigator.pop(context, true);
      setState(() {
        loading = false;
      });
    });
  }

  void deleteAlarm() {
    MyAlarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: saveAlarm,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        "Save",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.blueAccent),
                      ),
              ),
            ],
          ),
          Text(
            getDay(),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                TimeOfDay.fromDateTime(selectedDateTime).format(context),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: assetAudio,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/nokia.mp3',
                    child: Text('Nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/mozart.mp3',
                    child: Text('Mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/star_wars.mp3',
                    child: Text('Star Wars'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/one_piece.mp3',
                    child: Text('One Piece'),
                  ),
                ],
                onChanged: (value) => setState(() => assetAudio = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Action",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: action,
                items: const [
                  DropdownMenuItem<AlarmAction>(
                    value: AlarmAction.math,
                    child: Text('Math'),
                  ),
                ],
                onChanged: (value) => setState(() => action = value!),
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
                value: taskRepeat,
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
                onChanged: (value) => setState(() => taskRepeat = value!),
              ),
              Text(
                "Difficulty",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: difficulty,
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
                onChanged: (value) => setState(() => difficulty = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.5 : null),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        volume! > 0.7
                            ? Icons.volume_up_rounded
                            : volume! > 0.1
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded,
                      ),
                      Expanded(
                        child: Slider(
                          value: volume!,
                          onChanged: (value) {
                            setState(() => volume = value);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                'Delete Alarm',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );
  }
}
