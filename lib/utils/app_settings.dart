import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// 全局变量，用于保存设置
class AppSettings {
  static String username = ''; // 用户名
  static bool _initialized = false; // 标记是否已初始化
  static SharedPreferences? _prefs; // 缓存 SharedPreferences 实例

  // 初始化方法，确保插件正确加载
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // 等待 Flutter 引擎完全初始化
      await Future.delayed(const Duration(milliseconds: 100));
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      print('初始化 SharedPreferences 失败: $e');
      // 初始化失败，使用默认值
    }
  }

  // 加载保存的设置
  static Future<void> loadSettings() async {
    try {
      await init(); // 确保已初始化

      if (_prefs != null) {
        username = _prefs!.getString('username') ?? '';
      }
    } catch (e) {
      print('加载设置失败: $e');
      // 使用默认值
      username = '';
    }
  }

  // 保存设置
  static Future<void> saveSettings() async {
    try {
      await init(); // 确保已初始化

      if (_prefs != null) {
        await _prefs!.setString('username', username);
      }
    } catch (e) {
      print('保存设置失败: $e');
      // 处理错误但不中断应用流程
    }
  }
}
