import 'package:flutter/material.dart';

class TabViewContainer extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final int initialIndex;

  const TabViewContainer({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.initialIndex = 0,
  }) : assert(tabs.length == tabViews.length, "标签数量必须与页面数量一致");

  @override
  State<TabViewContainer> createState() => _TabViewContainerState();
}

class _TabViewContainerState extends State<TabViewContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  // 定义统一的动画持续时间和曲线，确保一致性
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
      animationDuration: animationDuration, // 设置TabController动画持续时间
    );

    // 监听滑动变化，确保TabBar和内容视图同步更新
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // 更新UI以反映新的选中标签
      if (_currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    }
  }

  // 切换到指定的索引
  void _switchToIndex(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _tabController.animateTo(
        index,
        duration: animationDuration,
        curve: animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算单个标签宽度
    final tabBarWidth = MediaQuery.of(context).size.width - 100; // 减去左右边距
    final tabWidth = tabBarWidth / 2; // 只有2个标签，各占50%

    return Column(
      children: [
        // 自定义TabBar，固定在顶部
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
          height: 30, // 固定高度更可控
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Stack(
            children: [
              // 平移的白色背景条
              AnimatedPositioned(
                duration: animationDuration,
                curve: animationCurve,
                left: _currentIndex * tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.all(2), // 添加小边距，修复圆角问题
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13.0), // 略小于外层圆角
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              // 两个点击区域，使用InkWell替代GestureDetector，并设置behavior
              Row(
                children: [
                  // 左侧区域 - 日视图
                  Expanded(
                    child: Material(
                      color: Colors.transparent, // 必须为Material设置透明背景
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0),
                        ),
                        splashFactory: NoSplash.splashFactory, // 禁用水波纹效果
                        highlightColor: Colors.transparent, // 禁用高亮效果
                        onTap: () => _switchToIndex(0),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: animationDuration,
                            curve: animationCurve,
                            style: TextStyle(
                              color: _currentIndex == 0
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: _currentIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            child: Text(widget.tabs[0]),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 右侧区域 - 周视图
                  Expanded(
                    child: Material(
                      color: Colors.transparent, // 必须为Material设置透明背景
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        ),
                        splashFactory: NoSplash.splashFactory, // 禁用水波纹效果
                        highlightColor: Colors.transparent, // 禁用高亮效果
                        onTap: () => _switchToIndex(1),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: animationDuration,
                            curve: animationCurve,
                            style: TextStyle(
                              color: _currentIndex == 1
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: _currentIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            child: Text(widget.tabs[1]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 内容区域，使用最简单的IndexedStack
        Expanded(
          child: IndexedStack(index: _currentIndex, children: widget.tabViews),
        ),
      ],
    );
  }
}
