import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:flutter/material.dart';

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
    this.fontSize = 24,
  });

  final List<StylizedTabPage> tabs;
  final bool upsideDown;
  final double fontSize;

  @override
  State<StylizedTabs> createState() => _StylizedTabsState();
}

class _StylizedTabsState extends State<StylizedTabs> {
  int currentIndex = 0;
  int previousIndex = 0;

  void _handleTap(int index) {
    if (widget.tabs[index].onTap != null) {
      widget.tabs[index].onTap!();
    }
    setState(() {
      previousIndex = currentIndex;
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 340,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.tabs.length,
              (index) => Expanded(
                child: StylizedTab(
                  isLast: index == widget.tabs.length - 1,
                  title: widget.tabs[index].title,
                  isActive: index == currentIndex,
                  index: index,
                  upsideDown: widget.upsideDown,
                  fontSize: widget.fontSize,
                  onTap: () => _handleTap(index),
                ),
              ),
            ),
          ),
        ),
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
