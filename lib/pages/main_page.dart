import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/pages/day_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('时间监控'), centerTitle: true),
      body: const DayView(title: '日'),
    );
  }
}
