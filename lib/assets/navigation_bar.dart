import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.onPageChanged,
    required this.currentIndex,
  });

  final Function(int) onPageChanged;
  final int currentIndex;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.percent,
      Icons.list,
      Icons.home,
      Icons.notifications,
      Icons.person,
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 45, left: 10, right: 10),
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 10,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  icons.length,
                  (index) {
                    final isSelected = widget.currentIndex == index;
                    final wasSelected = _previousIndex == index;

                    Animation<double> animation;
                    if (isSelected) {
                      animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Cubic(.21, .88, 1, .93),
                        ),
                      );
                    } else if (wasSelected) {
                      animation = Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Cubic(.21, .88, 1, .93),
                        ),
                      );
                    } else {
                      animation = const AlwaysStoppedAnimation<double>(0.0);
                    }

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final verticalOffset = -10 * animation.value;
                        final scale = 1.0 + (0.25 * animation.value);

                        return Transform.translate(
                          offset: Offset(0, verticalOffset),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 18 * animation.value,
                                left: animation.value * 10,
                                right: animation.value * 10,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).focusColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(60),
                                    blurRadius: 3,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  icons[index],
                                  color: Color.lerp(
                                    Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor,
                                    Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .selectedItemColor,
                                    animation.value,
                                  ),
                                  size: 40 + (5 * animation.value),
                                ),
                                onPressed: () {
                                  widget.onPageChanged(index);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
