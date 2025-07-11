import 'package:flutter/material.dart';

class BodyView extends StatelessWidget {
  final String header;
  final String footer;
  final List<Widget> children;

  const BodyView({
    super.key,
    required this.header,
    required this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // 为 header 添加 Padding 和自定义样式
            Padding(
              padding: const EdgeInsets.only(left: 12.0), // 左侧 padding 5
              child: Text(
                header,
                style: TextStyle(
                  fontSize: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.fontSize, // 字体小一号
                  color: Colors.grey[600], // 灰色
                ),
              ),
            ),
          ],
        ),
        Column(children: [...children]),
        Row(
          children: [
            // 为 header 添加 Padding 和自定义样式
            Padding(
              padding: const EdgeInsets.only(left: 12.0), // 左侧 padding 5
              child: Text(
                footer,
                style: TextStyle(
                  fontSize: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.fontSize, // 字体小一号
                  color: Colors.grey[600], // 灰色
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
