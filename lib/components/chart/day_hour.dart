import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 创建颜色类
class AppColors {
  static const Color contentColorPurple = Colors.purple;
  static const Color contentColorCyan = Colors.cyan;
  static const Color contentColorBlue = Colors.blue;
}

// 创建图例组件
class Legend {
  final String name;
  final Color color;

  Legend(this.name, this.color);
}

class LegendsListWidget extends StatelessWidget {
  final List<Legend> legends;

  const LegendsListWidget({Key? key, required this.legends}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
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
          ],
        );
      }).toList(),
    );
  }
}

class BarChartSample6 extends StatelessWidget {
  BarChartSample6({super.key});

  final pilateColor = AppColors.contentColorPurple;
  final cyclingColor = AppColors.contentColorCyan;
  final quickWorkoutColor = AppColors.contentColorBlue;
  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(
    int x,
    double pilates,
    double quickWorkout,
    double cycling,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(fromY: 0, toY: pilates, color: pilateColor, width: 5),
        BarChartRodData(
          fromY: pilates + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout,
          color: quickWorkoutColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: pilates + betweenSpace + quickWorkout + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout + betweenSpace + cycling,
          color: cyclingColor,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 12, right: 12, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7月11日 今天',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '4小时44分钟',
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
                barGroups: [
                  generateGroupData(0, 0, 15, 5),
                  generateGroupData(1, 15, 10, 5),
                  generateGroupData(2, 5, 15, 10),
                  generateGroupData(3, 20, 0, 5),
                  generateGroupData(4, 18, 0, 10),
                  generateGroupData(5, 22, 0, 8),
                  generateGroupData(6, 0, 10, 5),
                  generateGroupData(7, 12, 15, 8),
                  generateGroupData(8, 25, 0, 15),
                  generateGroupData(9, 0, 15, 12),
                  generateGroupData(10, 0, 20, 10),
                  generateGroupData(11, 0, 15, 5),
                  generateGroupData(12, 25, 0, 5),
                  generateGroupData(13, 20, 15, 10),
                  generateGroupData(14, 0, 0, 15),
                  generateGroupData(15, 0, 15, 10),
                  generateGroupData(16, 12, 0, 15),
                  generateGroupData(17, 25, 0, 18),
                  generateGroupData(18, 0, 12, 5),
                  generateGroupData(19, 0, 15, 8),
                  generateGroupData(20, 15, 18, 0),
                  generateGroupData(21, 18, 15, 0),
                  generateGroupData(22, 15, 0, 10),
                  generateGroupData(23, 0, 15, 8),
                  generateGroupData(24, 15, 0, 5),
                ],
                maxY: 60,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 30,
                      color: pilateColor,
                      strokeWidth: 1,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 60,
                      color: cyclingColor,
                      strokeWidth: 1,
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
              Legend('娱乐', pilateColor),
              Legend('社交', quickWorkoutColor),
              Legend('学习', cyclingColor),
            ],
          ),
        ],
      ),
    );
  }
}
