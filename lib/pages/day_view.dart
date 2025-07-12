import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:time_monitor_mobile/components/body_view.dart';
import 'package:time_monitor_mobile/components/chart/day_hour.dart';
import 'package:time_monitor_mobile/components/chart/hot.dart';
import 'package:intl/intl.dart';
import 'package:time_monitor_mobile/pages/settings_page.dart';
import 'package:time_monitor_mobile/routes/page_route_transitions.dart';
import 'package:time_monitor_mobile/utils/app_settings.dart'; // Added import for AppSettings

class DayView extends StatefulWidget {
  final String title;

  const DayView({super.key, required this.title});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with SingleTickerProviderStateMixin {
  String _errorMessage = '';
  bool _isLoading = false; // 添加回loading状态
  Map<String, dynamic> _userData = {};
  Timer? _refreshTimer; // 添加定时器
  String _lastOnlineText = ''; // 添加最后在线时间文本
  bool _isOnline = false; // 是否在线

  // 添加日期相关变量
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  String _formattedDateText = '';

  // 添加闪烁动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 处理后的数据 - 初始化为空对象而不是null
  Map<int, List<Map<String, dynamic>>> _hourlyData = {};
  List<AppUsageData> _topApps = [];
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();

    // 初始化日期显示
    _formattedDateText = _formatDateForDisplay(_selectedDate);

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(_animationController);

    // 首次加载数据，显示loading
    _fetchUserData(showLoading: true);

    // 设置定时器，每6秒刷新一次数据，但仅当显示当天数据时才自动刷新
    _refreshTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_isToday(_selectedDate)) {
        _fetchUserData(showLoading: false); // 自动刷新不显示loading
      }
    });
  }

  @override
  void dispose() {
    // 销毁定时器和动画控制器，避免内存泄漏
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // 检查是否是今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 格式化日期用于显示
  String _formatDateForDisplay(DateTime date) {
    if (_isToday(date)) {
      return '今天';
    }

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return '昨天';
    }

    return '${date.month}月${date.day}日';
  }

  // 切换到前一天
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _formattedDateText = _formatDateForDisplay(_selectedDate);
      _fetchUserData(showLoading: true); // 手动切换日期，显示loading
    });
  }

  // 切换到后一天，但不能超过今天
  void _goToNextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedDate.isBefore(today)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _formattedDateText = _formatDateForDisplay(_selectedDate);
        _fetchUserData(showLoading: true); // 手动切换日期，显示loading
      });
    }
  }

  Future<void> _fetchUserData({required bool showLoading}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = '';
      });
    }

    try {
      // 使用设置中的用户名，如果为空则使用默认值 'guest'
      String username;
      try {
        username = AppSettings.username.isNotEmpty
            ? AppSettings.username
            : 'guest';
      } catch (e) {
        print('获取用户名失败，使用默认值: $e');
        username = 'guest'; // 出错时使用默认值
      }

      // 格式化日期为 API 请求
      final formattedDate = _dateFormatter.format(_selectedDate);
      print('正在获取日期 $formattedDate 的数据，用户名: $username');

      final response = await http.get(
        Uri.parse(
          'https://tms.xianyiapi.eu.org/?userName=$username&date=$formattedDate',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          'API响应成功: ${response.body.substring(0, min(100, response.body.length))}...',
        );

        setState(() {
          _userData = data;
          _processData(data);
          _updateLastOnlineText(data);
          _isLoading = false; // 无论是否显示loading，完成后都设置为false
        });
        print('数据处理完成: ${_hourlyData.length} 小时数据, ${_topApps.length} 个应用');
      } else {
        print('API请求失败，状态码: ${response.statusCode}');
        setState(() {
          _errorMessage = '请求失败，状态码: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('获取数据时发生错误: $e');
      setState(() {
        _errorMessage = '发生错误: $e';
        _isLoading = false;
      });
    }
  }

  // 更新最后在线时间文本
  void _updateLastOnlineText(Map<String, dynamic> data) {
    if (data.containsKey('lastTime') && data['lastTime'] != null) {
      try {
        final lastTimeStr = data['lastTime'];
        final lastTime = DateTime.parse(lastTimeStr);
        final now = DateTime.now();
        final difference = now.difference(lastTime);

        if (difference.inMinutes < 1) {
          _lastOnlineText = '在线';
          _isOnline = true;
        } else if (difference.inHours < 1) {
          _lastOnlineText = '最后在线时间: ${difference.inMinutes}分钟前';
          _isOnline = false;
        } else if (difference.inDays < 1) {
          _lastOnlineText = '最后在线时间: ${difference.inHours}小时前';
          _isOnline = false;
        } else {
          _lastOnlineText = '最后在线时间: ${difference.inDays}天前';
          _isOnline = false;
        }
      } catch (e) {
        print('解析lastTime时出错: $e');
        _lastOnlineText = '最后在线时间: 未知';
        _isOnline = false;
      }
    } else {
      _lastOnlineText = '最后在线时间: 未知';
      _isOnline = false;
    }
  }

  void _processData(Map<String, dynamic> data) {
    // 重置数据
    Map<String, AppUsageData> appUsage = {};
    _hourlyData = {};
    int totalSeconds = 0;

    if (data['code'] == 200 && data['data'] != null) {
      final List<dynamic> appData = data['data'];
      print('处理 ${appData.length} 条应用数据');

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

      print('数据处理完成: 总时间 $_totalMinutes 分钟');
    } else {
      print('API返回错误或数据为空: ${data['code']}');
      // 确保即使没有数据也初始化为空列表/Map
      _totalMinutes = 0;
      _topApps = [];
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

  // 构建在线状态指示器
  Widget _buildOnlineStatus() {
    if (_isOnline) {
      return Row(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(_lastOnlineText),
        ],
      );
    } else {
      return Text(_lastOnlineText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 添加左右滑动手势
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // 右滑，显示前一天
          _goToPreviousDay();
        } else if (details.primaryVelocity! < 0) {
          // 左滑，显示后一天，但不能超过今天
          _goToNextDay();
        }
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 显示错误信息（如果有）
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // 显示加载指示器或内容
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(
                          children: [
                            BodyView(
                              header: '屏幕使用时间',
                              footer: _buildOnlineStatus(),
                              children: [
                                DayHourChart(
                                  totalTimeText: _formatTotalTime(
                                    _totalMinutes,
                                  ),
                                  hourlyData: _hourlyData,
                                  selectedDate: _selectedDate, // 传递选中的日期
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            BodyView(
                              header: '最常使用',
                              footer: '',
                              children: [
                                HotChart(
                                  appUsageData: _convertToHotChartData(
                                    _topApps,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          // 添加设置按钮到右上角
          Positioned(
            top: -8,
            right: 8,
            child: TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(createSlidePageRoute(const SettingsPage()));
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '设置',
                style: TextStyle(
                  color: Color.fromARGB(222, 11, 145, 255),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
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
