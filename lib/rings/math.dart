import 'package:alarming/classes/math_questions.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class MathRingScreen extends StatefulWidget {
  final MyAlarmSettings alarmSettings;
  late final List<MathQuestions> questions = List.empty(growable: true);

  MathRingScreen({Key? key, required this.alarmSettings}) : super(key: key) {
    for (int i = 0; i < alarmSettings.extensionSettings.taskRepeat; i++) {
      questions.add(
          MathQuestions.generate(alarmSettings.extensionSettings.difficulty));
    }
  }

  @override
  State<MathRingScreen> createState() => _MathRingScreenState();
}

class _MathRingScreenState extends State<MathRingScreen> {
  int taskIndex = 0;
  final TextEditingController _controller = TextEditingController();

  Future<void> doneTask(BuildContext context) async {
    if (!context.mounted) return;

    if (_controller.text == widget.questions[taskIndex].answer.toString()) {
      if (taskIndex == widget.questions.length - 1) {
        // 全タスクが完了したらページ遷移する
        await MyAlarm.stop(widget.alarmSettings.id);
        if (context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        // タスクが一つ完了
        setState(() {
          taskIndex = taskIndex + 1;
        });

        // スヌーズアラームを一分延長
        final now = DateTime.now();
        await MyAlarm.set(
          settings: widget.alarmSettings.copyWith(
            dateTime: DateTime(
              now.year,
              now.month,
              now.day,
              now.hour,
              now.minute,
              0,
              0,
            ).add(
              const Duration(minutes: 1),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.questions[taskIndex].questions),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a search term',
                      ),
                    ),
                  )
                ],
              ),

              // 止める
              ElevatedButton(
                onPressed: () {
                  doneTask(context);
                },
                child: const Text("STOP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
