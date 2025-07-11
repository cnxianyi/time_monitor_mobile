import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/routes/page_route_transitions.dart';
import 'package:time_monitor_mobile/pages/detail_page.dart';

class HotChart extends StatelessWidget {
  final List<dynamic> appUsageData;

  const HotChart({super.key, required this.appUsageData});

  @override
  Widget build(BuildContext context) {
    // 如果没有数据，显示提示信息
    if (appUsageData.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('暂无应用使用数据')),
      );
    }

    // 将ListView替换为Column，使内容随屏幕一起滚动
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(appUsageData.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const Divider(height: 1);
        } else {
          return _buildListItem(context, appUsageData[index ~/ 2]);
        }
      }),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item) {
    // 将动态数据转换为我们需要的格式
    final String name = item is Map ? item['name'] ?? '' : item.name;
    final Color color = item is Map ? item['color'] ?? Colors.blue : item.color;
    final double progress = item is Map
        ? item['progress'] ?? 0.0
        : item.progress;
    final String formattedTime = item is Map
        ? item['formattedTime'] ?? '0分钟'
        : item.formattedTime;

    // 获取标题数据
    final List<dynamic> titles = item is Map
        ? item['titles'] ?? []
        : item.titles ?? [];

    // 获取应用图标
    IconData appIcon = _getIconForApp(name);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          createSlidePageRoute(
            DetailPage(
              title: _getDisplayName(name),
              icon: appIcon,
              progress: progress,
              description: formattedTime,
              color: color,
              appUsageData: titles.isNotEmpty
                  ? [
                      {
                        'name': _getDisplayName(name),
                        'progress': progress,
                        'formattedTime': formattedTime,
                        'titles': titles,
                      },
                    ]
                  : null,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(appIcon, color: color, size: 24),
            ),

            const SizedBox(width: 16),

            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    _getDisplayName(name),
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
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 3,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 描述
                      Expanded(
                        flex: 2,
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
      ),
    );
  }

  // 根据应用名称获取合适的图标
  IconData _getIconForApp(String appName) {
    appName = appName.toLowerCase();

    if (appName.contains('chrome')) {
      return Icons.public;
    } else if (appName.contains('goland') ||
        appName.contains('idea') ||
        appName.contains('code')) {
      return Icons.code;
    } else if (appName.contains('terminal')) {
      return Icons.terminal;
    } else if (appName.contains('finder')) {
      return Icons.folder;
    } else if (appName.contains('word') || appName.contains('docs')) {
      return Icons.description;
    } else if (appName.contains('excel') || appName.contains('sheets')) {
      return Icons.grid_on;
    } else if (appName.contains('outlook') || appName.contains('mail')) {
      return Icons.mail;
    } else if (appName.contains('spotify') || appName.contains('music')) {
      return Icons.music_note;
    } else if (appName.contains('zoom')) {
      return Icons.video_call;
    } else if (appName.contains('slack')) {
      return Icons.chat;
    } else if (appName.contains('discord')) {
      return Icons.chat_bubble;
    } else {
      return Icons.apps;
    }
  }

  // 获取应用的显示名称
  String _getDisplayName(String appName) {
    // 提取应用名称，移除路径和后缀
    String displayName = appName;

    // 针对特定应用优化显示名称
    if (appName.toLowerCase().contains('chrome')) {
      return 'Google Chrome';
    } else if (appName.toLowerCase().contains('goland')) {
      return 'GoLand';
    } else if (appName.toLowerCase().contains('idea')) {
      return 'IntelliJ IDEA';
    } else if (appName.toLowerCase() == 'finder') {
      return 'Finder';
    } else if (appName.toLowerCase().contains('terminal')) {
      return 'Terminal';
    } else if (appName.toLowerCase().contains('zoom')) {
      return 'Zoom';
    } else if (appName.toLowerCase().contains('slack')) {
      return 'Slack';
    }

    return displayName;
  }
}
