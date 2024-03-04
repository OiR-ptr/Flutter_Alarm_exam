import 'package:alarming/classes/math_questions.dart';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:flutter/material.dart';

class MathRingScreen extends StatefulWidget {
  final MyAlarmSettings alarmSettings;
  late final MathQuestions questions;

  MathRingScreen({Key? key, required this.alarmSettings}) : super(key: key) {
    questions = MathQuestions.generate(Difficulty.hard);
  }

  @override
  State<MathRingScreen> createState() => _MathRingScreenState();
}

class _MathRingScreenState extends State<MathRingScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> stopAlarm(BuildContext context) async {
    if (!context.mounted) return;

    if (_controller.text != widget.questions.answer.toString()) {
      return;
    }

    await MyAlarm.stop(widget.alarmSettings.id);
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.questions.questions),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("test"),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                stopAlarm(context);
              },
              child: const Text("STOP"),
            ),
          ],
        ),
      ),
    );
  }
}
