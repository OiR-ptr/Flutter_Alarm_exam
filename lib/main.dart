import 'dart:async';

import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/scenes/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await MyAlarm.init();

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: const AlarmHomeScreen(),
    ),
  );
}
