import 'package:alarming/classes/alarm_extension_settings.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmTile extends StatelessWidget {
  final MyAlarmSettings settings;
  final void Function() onPressed;
  final void Function()? onDismissed;

  const AlarmTile({
    Key? key,
    required this.settings,
    required this.onPressed,
    this.onDismissed,
  }) : super(key: key);

  TimeOfDay get settingTimeOfDay {
    return TimeOfDay(
      hour: settings.settings.dateTime.hour,
      minute: settings.settings.dateTime.minute,
    );
  }

  String get nextAlarmAt {
    return DateFormat.Md().format(settings.settings.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: onDismissed != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: RawMaterialButton(
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  alarmIcon,
                  Text(nextAlarmAt),
                  const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                  periodicDefinedText,
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settingTimeOfDay.format(context),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right_rounded, size: 35),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Action: "),
                  actionIcon,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get alarmIcon {
    return Icon(
      settings.isSnoozed
          ? Icons.snooze_sharp
          : settings.isPeriodic
              ? Icons.loop_sharp
              : Icons.bolt_sharp,
      size: 20,
    );
  }

  Widget get actionIcon {
    late IconData icon;
    switch (settings.extensionSettings.action) {
      case AlarmAction.math:
        icon = Icons.add_sharp;
      case AlarmAction.smile:
        icon = Icons.sentiment_very_satisfied_sharp;
      case AlarmAction.audio:
        icon = Icons.mic_sharp;
    }

    return Icon(
      icon,
      size: 20,
    );
  }

  Widget get periodicDefinedText {
    late String text;
    if (settings.isSnoozed) {
      text = "スヌーズ中";
    } else if (settings.isPeriodic) {
      text = settings.extensionSettings.ringsDayOfWeek
          .map(
            (e) => e.name.substring(0, 3).toUpperCase(),
          )
          .join(',');
    } else {
      text = "繰り返しなし";
    }

    return Text(text);
  }
}
