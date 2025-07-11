import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/components/bodyView.dart';

class DayView extends StatelessWidget {
  final String title;

  const DayView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 在 Column 外层包裹 Padding
      padding: const EdgeInsets.all(16.0), // 添加所有方向 16 像素的内边距
      child: Column(
        // Column 的其他属性，如 mainAxisAlignment, crossAxisAlignment 等
        children: const [
          BodyView(
            header: 'header',
            footer: 'footer',
            children: [Text('这是日视图内容'), Text('这是日视图内容')],
          ),
        ],
      ),
    );
  }
}
