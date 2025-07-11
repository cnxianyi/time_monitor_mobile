import 'package:flutter/material.dart';

// 添加模拟数据类，用于测试显示
class AppUsageDetail {
  final String name;
  final double progress;
  final String formattedTime;
  final List<TitleUsage>? titles; // 添加子标题使用情况

  AppUsageDetail({
    required this.name,
    required this.progress,
    required this.formattedTime,
    this.titles,
  });
}

// 添加标题使用情况类
class TitleUsage {
  final String title;
  final int seconds;
  final String formattedTime;
  final double progress;
  final int legend; // 添加legend字段，用于分类

  TitleUsage({
    required this.title,
    required this.seconds,
    required this.formattedTime,
    required this.progress,
    required this.legend, // 初始化legend字段
  });
}

// 添加类别统计数据类
class CategorySummary {
  final String name;
  final IconData icon;
  final Color color;
  int seconds;

  CategorySummary({
    required this.name,
    required this.icon,
    required this.color,
    this.seconds = 0,
  });

  String get formattedTime {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours小时$minutes分钟';
    } else {
      return '$minutes分钟';
    }
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final double progress;
  final String description;
  final Color color;
  final List<dynamic>? appUsageData; // 添加应用使用数据参数

  const DetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.description,
    required this.color,
    this.appUsageData, // 可选参数，用于传递实际数据
  });

  @override
  Widget build(BuildContext context) {
    // 使用传入的应用使用数据或创建模拟数据
    final List<AppUsageDetail> mostUsedApps = appUsageData != null
        ? _processAppUsageData(appUsageData!)
        : [
            AppUsageDetail(
              name: 'WeChat',
              progress: 0.8,
              formattedTime: '40分钟',
            ),
            AppUsageDetail(
              name: 'TikTok',
              progress: 0.6,
              formattedTime: '30分钟',
            ),
            AppUsageDetail(name: 'QQ', progress: 0.4, formattedTime: '20分钟'),
            AppUsageDetail(name: 'Weibo', progress: 0.2, formattedTime: '10分钟'),
          ];

    // 计算各个类别的总时间
    Map<int, CategorySummary> categorySummaries = _calculateCategorySummaries(
      mostUsedApps,
    );

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // 这部分内容才是你截图中的"社交"和"使用时间"
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
                        title, // 这个 title 是您截图中的"社交"大标题
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
            const SizedBox(height: 24),

            // 添加类别统计
            _buildCategorySummaries(categorySummaries),
            const SizedBox(height: 24),

            // 添加最常使用标题
            const Text(
              "最常使用",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 添加最常使用图表
            Expanded(
              child: MostUsedChart(
                appUsageData: mostUsedApps,
                parentColor: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建类别统计视图
  Widget _buildCategorySummaries(Map<int, CategorySummary> categorySummaries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "类别统计",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categorySummaries.values
            .map((category) => _buildCategoryItem(category))
            .toList(),
      ],
    );
  }

  // 构建单个类别项
  Widget _buildCategoryItem(CategorySummary category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  category.formattedTime,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 计算各个类别的总时间
  Map<int, CategorySummary> _calculateCategorySummaries(
    List<AppUsageDetail> apps,
  ) {
    // 初始化类别统计
    Map<int, CategorySummary> categorySummaries = {
      1: CategorySummary(
        name: '学习',
        icon: Icons.school,
        color: Colors.lightGreen,
      ),
      2: CategorySummary(name: '娱乐', icon: Icons.games, color: Colors.purple),
      3: CategorySummary(name: '社交', icon: Icons.people, color: Colors.blue),
      4: CategorySummary(
        name: '其他',
        icon: Icons.description,
        color: Colors.grey,
      ),
    };

    // 累计各个类别的时间
    for (var app in apps) {
      if (app.titles != null) {
        for (var title in app.titles!) {
          int legendKey = title.legend;
          if (categorySummaries.containsKey(legendKey)) {
            categorySummaries[legendKey]!.seconds += title.seconds;
          }
        }
      }
    }

    return categorySummaries;
  }

  // 处理应用使用数据
  List<AppUsageDetail> _processAppUsageData(List<dynamic> data) {
    // 将原始数据转换为 AppUsageDetail 列表
    List<AppUsageDetail> result = [];

    // 用于存储所有标题的时间，以便找出最大值
    List<int> allTitleSeconds = [];

    // 首先收集所有标题的时间数据
    for (var item in data) {
      if (item['titles'] != null && item['titles'] is List) {
        Map<String, Map<String, dynamic>> mergedTitles = {};

        // 合并相同的标题
        for (var titleItem in item['titles']) {
          String titleText = titleItem['title'] ?? '';
          int seconds = titleItem['seconds'] ?? 0;
          int legend = titleItem['legend'] ?? 4; // 获取legend字段，默认为4（其他）

          // 如果标题已存在，累加时间
          if (mergedTitles.containsKey(titleText)) {
            mergedTitles[titleText]!['seconds'] =
                mergedTitles[titleText]!['seconds'] + seconds;
          } else {
            mergedTitles[titleText] = {'seconds': seconds, 'legend': legend};
          }
        }

        // 收集所有标题的秒数
        allTitleSeconds.addAll(
          mergedTitles.values.map((v) => v['seconds'] as int),
        );
      }
    }

    // 找出最大秒数值
    int maxSeconds = allTitleSeconds.isEmpty
        ? 3600
        : allTitleSeconds.reduce((a, b) => a > b ? a : b);

    // 处理每个应用的数据
    for (var item in data) {
      final String name = item['name'] ?? '';
      final double progress = item['progress'] ?? 0.0;
      final String formattedTime = item['formattedTime'] ?? '0分钟';

      // 处理标题数据，如果有的话
      List<TitleUsage>? titles;
      if (item['titles'] != null && item['titles'] is List) {
        // 用于合并相同标题的Map
        Map<String, Map<String, dynamic>> mergedTitles = {};

        // 合并相同的标题
        for (var titleItem in item['titles']) {
          String titleText = titleItem['title'] ?? '';
          int seconds = titleItem['seconds'] ?? 0;
          int legend = titleItem['legend'] ?? 4; // 获取legend字段，默认为4（其他）

          // 如果标题已存在，累加时间
          if (mergedTitles.containsKey(titleText)) {
            mergedTitles[titleText]!['seconds'] =
                mergedTitles[titleText]!['seconds'] + seconds;
          } else {
            mergedTitles[titleText] = {'seconds': seconds, 'legend': legend};
          }
        }

        // 将合并后的数据转换为TitleUsage列表，使用最大秒数作为进度条的基准
        titles = mergedTitles.entries.map((entry) {
          return TitleUsage(
            title: entry.key,
            seconds: entry.value['seconds'] as int,
            formattedTime: _formatSeconds(entry.value['seconds'] as int),
            progress:
                (entry.value['seconds'] as int) / maxSeconds, // 使用最大秒数作为分母
            legend: entry.value['legend'] as int, // 添加legend字段
          );
        }).toList();

        // 按使用时间排序
        titles.sort((a, b) => b.seconds.compareTo(a.seconds));
      }

      result.add(
        AppUsageDetail(
          name: name,
          progress: progress,
          formattedTime: formattedTime,
          titles: titles,
        ),
      );
    }

    return result;
  }

  // 格式化秒数为可读时间
  String _formatSeconds(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours小时$minutes分钟';
    } else {
      return '$minutes分钟';
    }
  }

  String _calculateWeekUsage(String description) {
    try {
      // 根据不同的时间格式进行处理
      if (description.contains('小时')) {
        // 格式为"X小时Y分钟"
        final parts = description.split('小时');
        final hours = double.parse(parts[0]);
        final minutes = int.parse(parts[1].replaceAll('分钟', ''));

        final weekHours = (hours * 7).floorToDouble(); // 向下取整
        final weekMinutes = (minutes * 7) % 60; // 可能超过60分钟的部分计入小时
        final additionalHours = ((minutes * 7) ~/ 60).toDouble();

        final totalWeekHours = weekHours + additionalHours;

        return '${totalWeekHours.toStringAsFixed(0)}小时${weekMinutes.toStringAsFixed(0).replaceAll('.0', '')}分钟';
      } else {
        // 格式为"X分钟"
        final minutes = int.parse(description.replaceAll('分钟', ''));
        final totalWeekMinutes = minutes * 7;

        if (totalWeekMinutes >= 60) {
          final weekHours = totalWeekMinutes ~/ 60;
          final weekMinutes = totalWeekMinutes % 60;
          return '$weekHours小时$weekMinutes分钟';
        } else {
          return '${totalWeekMinutes}分钟';
        }
      }
    } catch (e) {
      print('Error calculating week usage: $e');
      return '计算错误';
    }
  }

  String _calculateLastWeekUsage(String description) {
    try {
      // 根据不同的时间格式进行处理
      if (description.contains('小时')) {
        // 格式为"X小时Y分钟"
        final parts = description.split('小时');
        final hours = double.parse(parts[0]);
        final minutes = int.parse(parts[1].replaceAll('分钟', ''));

        final totalMinutes = (hours * 60 + minutes) * 0.8; // 取80%
        final lastWeekHours = totalMinutes ~/ 60;
        final lastWeekMinutes = totalMinutes % 60;

        return '$lastWeekHours小时${lastWeekMinutes.toStringAsFixed(0).replaceAll('.0', '')}分钟';
      } else {
        // 格式为"X分钟"
        final minutes = int.parse(description.replaceAll('分钟', ''));
        final lastWeekMinutes = (minutes * 0.8).round();

        if (lastWeekMinutes >= 60) {
          final lastWeekHours = lastWeekMinutes ~/ 60;
          final remainingMinutes = lastWeekMinutes % 60;
          return '$lastWeekHours小时$remainingMinutes分钟';
        } else {
          return '${lastWeekMinutes}分钟';
        }
      }
    } catch (e) {
      print('Error calculating last week usage: $e');
      return '计算错误';
    }
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

// 添加最常使用图表组件
class MostUsedChart extends StatelessWidget {
  final List<AppUsageDetail> appUsageData;
  final Color parentColor;

  const MostUsedChart({
    super.key,
    required this.appUsageData,
    required this.parentColor,
  });

  @override
  Widget build(BuildContext context) {
    // 如果没有数据，显示提示信息
    if (appUsageData.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('暂无应用使用数据')),
      );
    }

    // 提取所有标题项
    List<TitleUsage> allTitles = [];
    for (var app in appUsageData) {
      if (app.titles != null && app.titles!.isNotEmpty) {
        allTitles.addAll(app.titles!);
      }
    }

    // 按使用时间排序
    allTitles.sort((a, b) => b.seconds.compareTo(a.seconds));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 禁用滚动，让父级ScrollView处理滚动
      itemCount: allTitles.length,
      itemBuilder: (context, index) {
        final titleItem = allTitles[index];
        return _buildTitleItem(titleItem);
      },
    );
  }

  // 构建标题项
  Widget _buildTitleItem(TitleUsage titleItem) {
    // 根据legend字段选择图标
    IconData itemIcon;
    switch (titleItem.legend) {
      case 1:
        itemIcon = Icons.school; // 学习
        break;
      case 2:
        itemIcon = Icons.games; // 娱乐
        break;
      case 3:
        itemIcon = Icons.people; // 社交
        break;
      case 4:
      default:
        itemIcon = Icons.description; // 其他
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: parentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(itemIcon, color: parentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleItem.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: titleItem.progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            parentColor,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                        titleItem.formattedTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
