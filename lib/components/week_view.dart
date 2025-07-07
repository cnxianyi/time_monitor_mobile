import 'package:flutter/material.dart';

class WeekView extends StatelessWidget {
  final String title;

  const WeekView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('$title视图', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          const Text('这是周视图内容', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
