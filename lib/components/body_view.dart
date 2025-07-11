import 'package:flutter/material.dart';

class BodyView extends StatelessWidget {
  final String header;
  final dynamic footer; // 修改为dynamic类型，可以接受String或Widget
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
              padding: const EdgeInsets.only(left: 24.0), // 左侧 padding 5
              child: Text(
                header,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600], // 灰色
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          padding: const EdgeInsets.all(8),
          child: Column(children: [...children]),
        ),
        Row(
          children: [
            // 为 footer 添加 Padding 和自定义样式
            Padding(
              padding: const EdgeInsets.only(left: 24.0), // 左侧 padding 5
              child: footer is Widget
                  ? footer
                  : Text(
                      footer.toString(),
                      style: TextStyle(
                        fontSize: 12,
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
