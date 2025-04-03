import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedTabPage {
  const StylizedTabPage({
    required this.title,
    required this.child,
    this.onTap,
  });

  final StylizedTabTitle title;
  final Widget child;
  final VoidCallback? onTap;
}

class StylizedTabs extends StatefulWidget {
  const StylizedTabs({
    super.key,
    required this.tabs,
    this.upsideDown = false,
    this.fontSize = 16,
  });

  final List<StylizedTabPage> tabs;
  final bool upsideDown;
  final double fontSize;

  @override
  State<StylizedTabs> createState() => _StylizedTabsState();
}

class _StylizedTabsState extends State<StylizedTabs>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int previousIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (widget.tabs[index].onTap != null) {
      widget.tabs[index].onTap!();
    }
    setState(() {
      previousIndex = currentIndex;
      currentIndex = index;
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.tabs.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(index),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final isActive = index == currentIndex;
                      final wasActive = index == previousIndex;
                      final progress = isActive
                          ? _controller.value
                          : (wasActive ? 1 - _controller.value : 0.0);

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: widget.tabs[index].title.isIcon
                              ? Icon(
                                  widget.tabs[index].title.value as IconData,
                                  color: Color.lerp(
                                    Colors.white.withOpacity(0.5),
                                    Colors.white,
                                    progress,
                                  ),
                                  size: widget.fontSize + 9,
                                )
                              : Text(
                                  widget.tabs[index].title.value as String,
                                  style: GoogleFonts.poppins(
                                    color: Color.lerp(
                                      Colors.white.withOpacity(0.5),
                                      Colors.white,
                                      progress,
                                    ),
                                    fontSize: widget.fontSize,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          fit: FlexFit.loose,
          child: CarouselSwitch(
            direction: currentIndex < previousIndex
                ? CarouselSwitchDirection.right
                : CarouselSwitchDirection.left,
            child: KeyedSubtree(
              key: ValueKey(currentIndex),
              child: widget.tabs[currentIndex].child,
            ),
          ),
        ),
      ],
    );
  }
}
