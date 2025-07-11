import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:time_monitor_mobile/components/body_view.dart';
import 'package:time_monitor_mobile/components/chart/day_hour.dart';
import 'package:time_monitor_mobile/components/chart/hot.dart';

class DayView extends StatefulWidget {
  final String title;

  const DayView({super.key, required this.title});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _userData = {};
  Timer? _refreshTimer; // 添加定时器

  // 处理后的数据
  Map<int, List<Map<String, dynamic>>> _hourlyData = {};
  List<AppUsageData> _topApps = [];
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    // 设置定时器，每6秒刷新一次数据
    _refreshTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      _fetchUserData();
    });
  }

  @override
  void dispose() {
    // 销毁定时器，避免内存泄漏
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = false;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://tms.xianyiapi.eu.org/?userName=xianyi'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data;
          _processData(data);
          _isLoading = false;
        });
        print('Data fetched successfully: ${_userData.toString()}');
      } else {
        setState(() {
          _errorMessage = '请求失败，状态码: ${response.statusCode}';
          _isLoading = false;
        });
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '发生错误: $e';
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _processData(Map<String, dynamic> data) {
    if (data['code'] == 200 && data['data'] != null) {
      final List<dynamic> appData = data['data'];

      // 总使用时间（秒）
      int totalSeconds = 0;

      // 临时存储按应用程序分组的数据
      Map<String, AppUsageData> appUsage = {};

      // 按小时分组的数据
      _hourlyData = {};

      // 处理每个应用的数据
      for (var app in appData) {
        final String process = app['process'];
        final int hour = app['hour'];
        final List<dynamic> titles = app['titles'];

        // 初始化小时数据
        if (!_hourlyData.containsKey(hour)) {
          _hourlyData[hour] = [];
        }

        // 处理该应用在该小时的各个标题
        for (var titleData in titles) {
          final String title = titleData['title'];
          final int seconds = titleData['time'];
          final int legend = titleData['legend'] ?? 4; // 获取legend字段，默认为4（其他）

          totalSeconds += seconds;

          // 为小时数据添加记录
          _hourlyData[hour]!.add({
            'process': process,
            'title': title,
            'seconds': seconds,
            'legend': legend, // 添加legend字段
          });

          // 按应用汇总
          if (!appUsage.containsKey(process)) {
            appUsage[process] = AppUsageData(
              name: process,
              seconds: 0,
              color: _getColorForApp(process),
              titles: [], // 初始化标题列表
            );
          }

          // 增加应用的总使用时间
          appUsage[process]!.seconds += seconds;

          // 添加标题数据到应用
          appUsage[process]!.titles.add({
            'title': title,
            'seconds': seconds,
            'legend': legend, // 添加legend字段
          });
        }
      }

      // 转换总秒数为分钟，用于显示
      _totalMinutes = totalSeconds ~/ 60;

      // 转换为列表并排序
      _topApps = appUsage.values.toList()
        ..sort((a, b) => b.seconds.compareTo(a.seconds));
    }
  }

  Color _getColorForApp(String process) {
    // 根据应用名分配固定颜色
    if (process.contains('chrome')) {
      return Colors.blue;
    } else if (process.contains('goland')) {
      return Colors.green;
    } else if (process.contains('idea')) {
      return Colors.purple;
    } else if (process.contains('finder')) {
      return Colors.orange;
    } else if (process.contains('terminal')) {
      return Colors.red;
    } else {
      // 为其他应用随机分配颜色
      return Colors.primaries[process.hashCode % Colors.primaries.length];
    }
  }

  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '$hours小时$mins分钟';
    } else {
      return '$mins分钟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserData,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  BodyView(
                    header: '屏幕使用时间',
                    footer:
                        '更新于: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    children: [
                      DayHourChart(
                        totalTimeText: _formatTotalTime(_totalMinutes),
                        hourlyData: _hourlyData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BodyView(
                    header: '最常使用',
                    footer: '',
                    children: [
                      HotChart(appUsageData: _convertToHotChartData(_topApps)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // 转换数据格式以适配 HotChart
  List<dynamic> _convertToHotChartData(List<AppUsageData> apps) {
    return apps.map((app) {
      return {
        'name': app.name,
        'minutes': app.minutes,
        'color': app.color,
        'progress': app.progress,
        'formattedTime': app.formattedTime,
        'titles': app.titles.map((title) {
          return {
            'title': title['title'],
            'seconds': title['seconds'],
            'legend': title['legend'], // 包含legend字段
          };
        }).toList(),
      };
    }).toList();
  }
}

// 定义应用使用数据模型
class AppUsageData {
  final String name;
  int seconds;
  final Color color;
  final List<Map<String, dynamic>> titles; // 添加标题列表

  AppUsageData({
    required this.name,
    required this.seconds,
    required this.color,
    required this.titles, // 初始化标题列表
  });

  int get minutes => seconds ~/ 60;

  String get formattedTime {
    final hours = seconds ~/ 3600; // 3600秒 = 1小时
    final mins = (seconds % 3600) ~/ 60; // 余下的秒数转换为分钟

    if (hours > 0) {
      return '$hours小时$mins分钟';
    } else {
      return '$mins分钟';
    }
  }

  double get progress {
    // 假设最大使用时间为5小时
    return seconds / (5 * 3600); // 5小时 = 5 * 3600秒
  }
}
