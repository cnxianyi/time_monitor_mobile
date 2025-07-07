import 'package:flutter/material.dart';
import 'package:time_monitor_mobile/pages/main_page.dart';

void main() {
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
