import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_monitor_mobile/pages/main_page.dart';
import 'package:time_monitor_mobile/utils/app_settings.dart';

Future<void> main() async {
  // 确保Flutter绑定初始化 - 这一步对于插件初始化非常重要
  // 必须在使用任何平台通道之前调用
  WidgetsFlutterBinding.ensureInitialized();

  // 设置应用方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // 初始化设置
    await AppSettings.init();
    print('设置初始化成功');

    // 加载保存的设置
    await AppSettings.loadSettings();
    print('设置加载成功');
  } catch (e) {
    print('加载设置时出错: $e');
    // 出错时不要阻止应用启动
  }

  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TimeMonitorMobile',
      theme: ThemeData(
        brightness: Brightness.light, // 你可以保持为 light，或者根据需要调整
        scaffoldBackgroundColor: Colors.white,
        // 修改 AppBarTheme 来让顶部不变化，跟随系统
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.purpleAccent),
          toolbarHeight: 0,
        ),
      ),
      // 使用新的MainPage作为主页
      home: const MainPage(title: 'TMM'),
    );
  }
}
