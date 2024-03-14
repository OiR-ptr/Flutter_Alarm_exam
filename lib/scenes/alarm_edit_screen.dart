import 'package:alarm/alarm.dart';
import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/widgets/alarm_action_bottomsheet.dart';
import 'package:alarming/widgets/alarm_periodic_bottomsheet.dart';
import 'package:flutter/material.dart';

class AlarmEditScreen extends StatefulWidget {
  final MyAlarmSettings? alarmSettings;

  const AlarmEditScreen({Key? key, this.alarmSettings}) : super(key: key);

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late MyAlarmSettings drafting;

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      final now = DateTime.now();
      final id = DateTime.now().millisecondsSinceEpoch % 10000;
      drafting = MyAlarmSettings(
        id: id,
        settings: AlarmSettings(
          id: id,
          dateTime: now
              .add(const Duration(minutes: 1))
              .copyWith(second: 0, millisecond: 0),
          volume: 0.5,
          loopAudio: true,
          vibrate: true,
          assetAudioPath: 'assets/marimba.mp3',
          notificationTitle: 'Alarm example',
          notificationBody: 'Your alarm ($id) is ringing',
        ),
        extensionSettings: AlarmExtensionSettings(
          id: id,
          action: AlarmAction.math,
          taskRepeat: 1,
          difficulty: Difficulty.normal,
          ringsDayOfWeek: [],
          alarmAt: Duration(
            hours: now.hour,
            minutes: now.minute + 1,
          ),
          isSnooze: false,
          label: "",
        ),
      );
    } else {
      drafting = widget.alarmSettings!;
    }
  }

  Future<void> pickTime() async {
    final selectedDateTime = drafting.settings.dateTime;
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final DateTime now = DateTime.now();
        DateTime draftTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (draftTime.isBefore(now)) {
          draftTime = draftTime.add(const Duration(days: 1));
        }

        drafting = drafting.copyWith(
          dateTime: draftTime,
          alarmAt: Duration(
            hours: draftTime.hour,
            minutes: draftTime.minute,
          ),
        );
      });
    }
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);

    MyAlarm.set(settings: drafting).then((res) {
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

  void skipAlarm() {
    MyAlarm.stop(widget.alarmSettings!.id).then((isOk) {
      if (isOk) {
        MyAlarm.setPeriodic(settings: widget.alarmSettings!).then((any) {
          Navigator.pop(context, true);
        });
      }
    });
  }

  Future popPeriodicBottomSheet(BuildContext context) async {
    final AlarmPeriodicBottomSheetDone? done = await showModalBottomSheet(
      context: context,
      builder: (context) => AlarmPeriodicBottomSheet(
        alarmSettings: drafting,
      ),
    );
    if (done != null) {
      setState(() {
        drafting = drafting.copyWith(
          ringsDayOfWeek: done.rings,
        );
      });
    }
  }

  Future popActionBottomSheet(BuildContext context) async {
    final AlarmActionBottomSheetDone? done = await showModalBottomSheet(
      context: context,
      builder: (context) => AlarmActionBottomSheet(
        alarmSettings: widget.alarmSettings,
      ),
    );
    if (done != null) {
      setState(() {
        drafting = drafting.copyWith(
          action: done.action,
          taskRepeat: done.taskRepeat,
          difficulty: done.difficulty,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT ALARM"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RawMaterialButton(
                onPressed: drafting.isSnoozed ? null : pickTime,
                fillColor: Colors.grey[200],
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Text(
                    TimeOfDay.fromDateTime(drafting.settings.dateTime)
                        .format(context),
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
                  const Text("繰り返し"),
                  TextButton.icon(
                    onPressed: () => popPeriodicBottomSheet(context),
                    icon: const Icon(Icons.chevron_right),
                    label: _getPeriodicDefined(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("アクション選択"),
                  TextButton.icon(
                    onPressed: () => popActionBottomSheet(context),
                    icon: const Icon(Icons.chevron_right),
                    label: _getActionDefined(),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      drafting.settings.volume! > 0.7
                          ? Icons.volume_up_rounded
                          : drafting.settings.volume! > 0.1
                              ? Icons.volume_down_rounded
                              : Icons.volume_mute_rounded,
                    ),
                    Expanded(
                      child: Slider(
                        value: drafting.settings.volume!,
                        onChanged: (value) {
                          setState(() {
                            drafting = drafting.copyWith(volume: value);
                          });
                        },
                      ),
                    ),
                  ],
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
                    value: drafting.settings.assetAudioPath,
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
                    onChanged: (value) => setState(() {
                      drafting = drafting.copyWith(assetAudioPath: value);
                    }),
                  ),
                ],
              ),
              _cancelAction(context),
              TextButton(
                onPressed: () => saveAlarm(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("保存"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getActionDefined() {
    String btnText =
        "${drafting.extensionSettings.action.name} x${drafting.extensionSettings.taskRepeat.toString()}";
    return Text(btnText);
  }

  Widget _getPeriodicDefined() {
    String text;
    if (drafting.isPeriodic) {
      text = drafting.extensionSettings.ringsDayOfWeek
          .map((e) => e.name.substring(0, 3).toUpperCase())
          .join(',');
    } else {
      text = "繰り返しなし";
    }
    return Text(text);
  }

  Widget _cancelAction(BuildContext context) {
    if (creating) return Container();

    if (drafting.isSnoozed) {
      return TextButton(
        onPressed: skipAlarm,
        child: Text(
          'Finish Snnoze',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.red),
        ),
      );
    }

    return TextButton(
      onPressed: deleteAlarm,
      child: Text(
        'Delete Alarm',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Colors.red),
      ),
    );
  }
}
