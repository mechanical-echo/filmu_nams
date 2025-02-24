import 'package:flutter/material.dart';

class StylizedCarousel extends StatefulWidget {
  final List<Widget> items;

  const StylizedCarousel({super.key, required this.items});

  @override
  _StylizedCarouselState createState() => _StylizedCarouselState();
}

class _StylizedCarouselState extends State<StylizedCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: widget.items.length * 1000,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        int actualIndex = index % widget.items.length;
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            }
            return Center(
              child: SizedBox(
                height: Curves.easeOut.transform(value) * 300,
                width: Curves.easeOut.transform(value) * 300,
                child: child,
              ),
            );
          },
          child: Opacity(
            opacity: _currentPage == actualIndex ? 1.0 : 0.5,
            child: widget.items[actualIndex],
          ),
        );
      },
      onPageChanged: (index) {
        setState(() {
          _currentPage = index % widget.items.length;
        });
      },
    );
  }
}
