import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 创建颜色类
class AppColors {
  static const Color contentColorPurple = Colors.purple;
  static const Color contentColorCyan = Colors.cyan;
  static const Color contentColorBlue = Colors.blue;
  static const Color contentColorGreen = Colors.lightGreen;
  static const Color contentColorGrey = Colors.grey;
}

// 创建图例组件
class Legend {
  final String name;
  final Color color;
  final String? timeText; // 添加时间文本

  Legend(this.name, this.color, {this.timeText});
}

class LegendsListWidget extends StatelessWidget {
  final List<Legend> legends;

  const LegendsListWidget({super.key, required this.legends});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8, // 添加行间距
      children: legends.map((legend) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: legend.color,
              ),
            ),
            const SizedBox(width: 4),
            Text(legend.name, style: const TextStyle(fontSize: 12)),
            if (legend.timeText != null) ...[
              const SizedBox(width: 4),
              Text(
                legend.timeText!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        );
      }).toList(),
    );
  }
}

class DayHourChart extends StatelessWidget {
  final String totalTimeText;
  final Map<int, List<Map<String, dynamic>>> hourlyData;

  DayHourChart({
    super.key,
    required this.totalTimeText,
    required this.hourlyData,
  });

  // 更新颜色定义，对应不同类别
  final studyColor = AppColors.contentColorGreen; // 学习 - 绿色
  final entertainmentColor = AppColors.contentColorPurple; // 娱乐 - 紫色
  final socialColor = AppColors.contentColorBlue; // 社交 - 蓝色
  final otherColor = AppColors.contentColorGrey; // 其他 - 灰色
  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(
    int x,
    double study,
    double entertainment,
    double social,
    double other,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(fromY: 0, toY: study, color: studyColor, width: 5),
        BarChartRodData(
          fromY: study + betweenSpace,
          toY: study + betweenSpace + entertainment,
          color: entertainmentColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: study + betweenSpace + entertainment + betweenSpace,
          toY: study + betweenSpace + entertainment + betweenSpace + social,
          color: socialColor,
          width: 5,
        ),
        BarChartRodData(
          fromY:
              study +
              betweenSpace +
              entertainment +
              betweenSpace +
              social +
              betweenSpace,
          toY:
              study +
              betweenSpace +
              entertainment +
              betweenSpace +
              social +
              betweenSpace +
              other,
          color: otherColor,
          width: 5,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0时';
        break;
      case 1:
        text = '';
        break;
      case 2:
        text = '2时';
        break;
      case 3:
        text = '';
        break;
      case 4:
        text = '4时';
        break;
      case 5:
        text = '';
        break;
      case 6:
        text = '6时';
        break;
      case 7:
        text = '';
        break;
      case 8:
        text = '8时';
        break;
      case 9:
        text = '';
        break;
      case 10:
        text = '10时';
        break;
      case 11:
        text = '';
        break;
      case 12:
        text = '12时';
        break;
      case 13:
        text = '';
        break;
      case 14:
        text = '14时';
        break;
      case 15:
        text = '';
        break;
      case 16:
        text = '16时';
        break;
      case 17:
        text = '';
        break;
      case 18:
        text = '18时';
        break;
      case 19:
        text = '';
        break;
      case 20:
        text = '20时';
        break;
      case 21:
        text = '';
        break;
      case 22:
        text = '22时';
        break;
      case 23:
        text = '';
        break;
      case 24:
        text = '24时';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    List<BarChartGroupData> groups = [];

    // 按小时创建柱状图组
    for (int hour = 0; hour <= 24; hour++) {
      double study = 0; // 学习 - 绿色
      double entertainment = 0; // 娱乐 - 紫色
      double social = 0; // 社交 - 蓝色
      double other = 0; // 其他 - 灰色

      // 如果有该小时的数据，进行汇总
      if (hourlyData.containsKey(hour)) {
        for (var appData in hourlyData[hour]!) {
          int seconds = appData['seconds'];
          int legend = appData['legend'] ?? 4; // 默认为"其他"类别

          // 将秒转换为分钟，以便在图表中显示
          double minutes = seconds / 60;

          // 根据legend字段分类应用
          // 1-学习, 2-娱乐, 3-社交, 4-其他
          switch (legend) {
            case 1:
              study += minutes; // 学习
              break;
            case 2:
              entertainment += minutes; // 娱乐
              break;
            case 3:
              social += minutes; // 社交
              break;
            case 4:
            default:
              other += minutes; // 其他
              break;
          }
        }
      }

      groups.add(generateGroupData(hour, study, entertainment, social, other));
    }

    return groups;
  }

  // 计算各类别总时间
  Map<int, int> _calculateCategorySummaries() {
    Map<int, int> categorySummaries = {1: 0, 2: 0, 3: 0, 4: 0}; // 初始化各类别总秒数

    // 遍历所有小时数据
    hourlyData.forEach((hour, appDataList) {
      for (var appData in appDataList) {
        int seconds = appData['seconds'];
        int legend = appData['legend'] ?? 4; // 默认为"其他"类别

        // 累加各类别总时间
        if (categorySummaries.containsKey(legend)) {
          categorySummaries[legend] = categorySummaries[legend]! + seconds;
        }
      }
    });

    return categorySummaries;
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');

    // 计算各类别总时间
    final categorySummaries = _calculateCategorySummaries();

    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 12, right: 12, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$month月$day日 今天',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            totalTimeText,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 20,
                    ),
                  ),
                ),
                barTouchData: const BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: _generateBarGroups(),
                maxY: 60,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: Colors.grey[500],
                      strokeWidth: 0.5,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 15,
                      color: Colors.grey[500],
                      strokeWidth: 0.5,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 30,
                      color: Colors.grey[500],
                      strokeWidth: 0.5,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 45,
                      color: Colors.grey[500],
                      strokeWidth: 0.5,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 60,
                      color: Colors.grey[500],
                      strokeWidth: 0.5,
                      dashArray: [20, 4],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          LegendsListWidget(
            legends: [
              Legend(
                '学习',
                studyColor,
                timeText: _formatSeconds(categorySummaries[1]!),
              ),
              Legend(
                '娱乐',
                entertainmentColor,
                timeText: _formatSeconds(categorySummaries[2]!),
              ),
              Legend(
                '社交',
                socialColor,
                timeText: _formatSeconds(categorySummaries[3]!),
              ),
              Legend(
                '其他',
                otherColor,
                timeText: _formatSeconds(categorySummaries[4]!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
