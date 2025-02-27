import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:flutter/material.dart';

class StylizedTabPage {
  const StylizedTabPage({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;
}

class StylizedTabs extends StatefulWidget {
  const StylizedTabs({
    super.key,
    required this.tabs,
  });

  final List<StylizedTabPage> tabs;

  @override
  State<StylizedTabs> createState() => _StylizedTabsState();
}

class _StylizedTabsState extends State<StylizedTabs> {
  int currentIndex = 0;
  int previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.tabs.length,
            (index) => StylizedTab(
              isLast: index == widget.tabs.length - 1,
              title: widget.tabs[index].title,
              isActive: index == currentIndex,
              index: index,
              onTap: () {
                setState(() {
                  previousIndex = currentIndex;
                  currentIndex = index;
                });
              },
            ),
          ),
        ),
        CarouselSwitch(
          direction: currentIndex < previousIndex
              ? CarouselSwitchDirection.right
              : CarouselSwitchDirection.left,
          child: KeyedSubtree(
            key: ValueKey(currentIndex),
            child: widget.tabs[currentIndex].child,
          ),
        ),
      ],
    );
  }
}
