import 'package:flutter/material.dart';
import 'pages/home_page.dart';

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
      // 直接使用home而不是路由，因为现在使用自定义动画导航
      home: const MyHomePage(title: 'HOME'),
    );
  }
}
