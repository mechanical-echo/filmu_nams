import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      duration: const Duration(milliseconds: 450),
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

    final theme = ContextTheme.of(context);

    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: theme.roundCardDecoration,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
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
                            curve: Cubic(1, 0, 0, 1),
                          ),
                        );
                      } else if (wasSelected) {
                        animation = Tween<double>(begin: 1.0, end: 0.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Cubic(1, 0, 0, 1),
                          ),
                        );
                      } else {
                        animation = const AlwaysStoppedAnimation<double>(0.0);
                      }

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final flexFactor = 1 + animation.value;

                          return Flexible(
                            flex: (flexFactor * 10).round(),
                            child: GestureDetector(
                              onTap: () => widget.onPageChanged(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4 + (animation.value * 8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.0 + (0.1 * animation.value),
                                      child: Icon(
                                        icons[index],
                                        color: Color.lerp(
                                          theme.contrast.withOpacity(0.5),
                                          theme.primary,
                                          0.5 + (0.5 * animation.value),
                                        ),
                                        size: 28,
                                      ),
                                    ),
                                    ClipRect(
                                      child: SizedBox(
                                        height: animation.value * 20,
                                        child: Opacity(
                                          opacity: animation.value,
                                          child: Transform.translate(
                                            offset: Offset(
                                                0, 5 * (1 - animation.value)),
                                            child: Text(
                                              labels[index],
                                              style: GoogleFonts.poppins(
                                                color: theme.primary,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
