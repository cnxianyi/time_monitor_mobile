import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/components/tab_view_container.dart';
import 'package:time_monitor_mobile/pages/day_view.dart';
import 'package:time_monitor_mobile/pages/week_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // 定义视图内容
    final List<Widget> views = [
      const DayView(title: '日'),
      const WeekView(title: '周'),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: TabViewContainer(tabs: const ['日', '周'], tabViews: views),
    );
  }
}
