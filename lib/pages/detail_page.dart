import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final double progress;
  final String description;
  final Color color;

  const DetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(title), // 移除这里的 title，让自定义 leading 和 body 标题各司其职
        automaticallyImplyLeading: false, // 禁用自动返回按钮，因为我们要自定义
        leadingWidth: 80, // 增加宽度以容纳图标和文字
        leading: InkWell(
          // <-- 这是你的自定义返回按钮区域
          onTap: () {
            // 确保这里能正确执行 pop
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // 如果不能 pop (比如是home页)，可以打印日志或执行其他操作
              print('Cannot pop, this is likely the first page.');
            }
          },
          child: const Padding(
            // 使用 const Padding
            padding: EdgeInsets.only(left: 8.0), // 左侧留一点边距
            child: Row(
              // 使用 Row 来水平排列图标和文本
              mainAxisSize: MainAxisSize.min, // 让 Row 尽可能小
              children: [
                Icon(Icons.arrow_back_ios, size: 18), // 返回箭头图标
                SizedBox(width: 4), // 图标和文字之间的间距
                Text(
                  '返回', // 返回文字
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        // 如果你希望在AppBar中间有另一个标题，可以放在这里
        // title: Text('应用程序标题'), // 例如：这里可以放应用的通用标题，而不是DetailPage的title
        // centerTitle: true, // 让标题居中
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // 这部分内容才是你截图中的“社交”和“使用时间”
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // 这个 title 是您截图中的“社交”大标题
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "使用时间: $description",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ... 其他内容保持不变 ...
            const SizedBox(height: 24),
            Text(
              "使用进度",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "详细统计",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("本日使用", description),
            _buildDetailRow(
              "本周使用",
              "${(double.parse(description.split('小时')[0]) * 7).toStringAsFixed(1)}小时",
            ),
            _buildDetailRow(
              "上周同期",
              "${(double.parse(description.split('小时')[0]) * 0.8).toStringAsFixed(1)}小时",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
