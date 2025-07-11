import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/components/body_view.dart';
import 'package:time_monitor_mobile/components/chart/day_hour.dart';
import 'package:time_monitor_mobile/components/chart/hot.dart';

class DayView extends StatelessWidget {
  final String title;

  const DayView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        // 在 Column 外层包裹 Padding
        padding: const EdgeInsets.all(16.0), // 添加所有方向 16 像素的内边距
        child: Column(
          // Column 的其他属性，如 mainAxisAlignment, crossAxisAlignment 等
          children: [
            BodyView(
              header: '屏幕使用时间',
              footer: '更新于: 今天 12:00',
              children: [DayHourChart()],
            ),
            const SizedBox(height: 24),
            BodyView(header: '最常使用', footer: '', children: [HotChart()]),
          ],
        ),
      ),
    );
  }
}
