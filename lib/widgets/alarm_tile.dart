import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  final String nextDay;
  final String title;
  final void Function() onPressed;
  final void Function()? onDismissed;

  const AlarmTile({
    Key? key,
    required this.title,
    required this.nextDay,
    required this.onPressed,
    this.onDismissed,
  }) : super(key: key);

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
                  // TODO: スヌーズ中の時だけアイコンを出す
                  const Icon(Icons.snooze_sharp, size: 20),
                  Text(nextDay),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right_rounded, size: 35),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TODO: 繰り返し設定やアクション定義を把握できるようにする
                  Text("ミッション: 🔢"),
                  Text("月火水木金土日"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
