import 'package:flutter/material.dart';

class HotChart extends StatelessWidget {
  const HotChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 示例数据
    final List<HotItem> items = [
      HotItem(
        icon: Icons.chat,
        title: '社交',
        progress: 0.99,
        description: '3小时12分钟',
        color: Colors.orange,
      ),
      HotItem(
        icon: Icons.school,
        title: '学习',
        progress: 0.5,
        description: '2小时44分钟',
        color: Colors.blue,
      ),
      HotItem(
        icon: Icons.videogame_asset,
        title: '游戏',
        progress: 0.8,
        description: '4小时20分钟',
        color: Colors.purple,
      ),
      HotItem(
        icon: Icons.movie,
        title: '娱乐',
        progress: 0.6,
        description: '2小时56分钟',
        color: Colors.red,
      ),
      HotItem(
        icon: Icons.fitness_center,
        title: '健身',
        progress: 0.3,
        description: '1小时25分钟',
        color: Colors.green,
      ),
      HotItem(
        icon: Icons.movie,
        title: '娱乐',
        progress: 0.6,
        description: '2小时56分钟',
        color: Colors.red,
      ),
      HotItem(
        icon: Icons.fitness_center,
        title: '健身',
        progress: 0.3,
        description: '1小时25分钟',
        color: Colors.green,
      ),
    ];

    // 将ListView替换为Column，使内容随屏幕一起滚动
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const Divider(height: 1);
        } else {
          return _buildListItem(items[index ~/ 2]);
        }
      }),
    );
  }

  Widget _buildListItem(HotItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          // 左侧图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),

          const SizedBox(width: 16),

          // 中间内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // 进度条和描述
                Row(
                  children: [
                    // 进度条
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                          minHeight: 3,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 描述
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 右侧箭头
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
        ],
      ),
    );
  }
}

// 数据模型
class HotItem {
  final IconData icon;
  final String title;
  final double progress;
  final String description;
  final Color color;

  HotItem({
    required this.icon,
    required this.title,
    required this.progress,
    required this.description,
    required this.color,
  });
}
