import 'package:flutter/material.dart';

class DepthPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  DepthPageRoute({required this.page})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              // 使用3D效果的景深动画
              const begin = 0.0;
              const end = 0.1;
              var tween = Tween(begin: begin, end: end);
              var curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );

              return Stack(
                children: [
                  // 背景变暗效果
                  FadeTransition(
                    opacity: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(curvedAnimation),
                    child: Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  // 主要动画效果
                  AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 透视效果
                          ..translate(0.0)
                          ..scale(0.9 + 0.1 * animation.value),
                        alignment: Alignment.center,
                        child: Opacity(opacity: animation.value, child: child),
                      );
                    },
                    child: child,
                  ),
                ],
              );
            },
      );
}
