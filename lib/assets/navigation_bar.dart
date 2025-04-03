import 'package:filmu_nams/providers/color_context.dart';
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

    List<String> labels = [
      'Piedāvājumi',
      'Saraksts',
      'Sākums',
      'Paziņojumi',
      'Profils',
    ];

    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 85,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          curve: Curves.easeOutCubic,
                        ),
                      );
                    } else if (wasSelected) {
                      animation = Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                    } else {
                      animation = const AlwaysStoppedAnimation<double>(0.0);
                    }

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final scale = 1.0 + (0.1 * animation.value);
                        final opacity = 0.5 + (0.5 * animation.value);

                        return GestureDetector(
                          onTap: () => widget.onPageChanged(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    icons[index],
                                    color: Color.lerp(
                                      Colors.white.withOpacity(0.5),
                                      Colors.white,
                                      opacity,
                                    ),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: Color.lerp(
                                      Colors.white.withOpacity(0.5),
                                      Colors.white,
                                      opacity,
                                    ),
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
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
