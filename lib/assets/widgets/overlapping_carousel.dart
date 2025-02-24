import 'package:flutter/material.dart';

class OverlappingCarousel extends StatefulWidget {
  final List<Widget> items;
  final double itemWidth;
  final double itemHeight;
  final double scaleFactor;
  final double horizontalSpace;
  final double spacingFactor;

  const OverlappingCarousel({
    super.key,
    required this.items,
    required this.itemWidth,
    required this.itemHeight,
    this.scaleFactor = 0.8,
    this.horizontalSpace = 60,
    this.spacingFactor = 0.15,
  });

  @override
  State<OverlappingCarousel> createState() => _OverlappingCarouselState();
}

class _OverlappingCarouselState extends State<OverlappingCarousel> {
  late PageController _pageController;
  double _currentPage = 0;
  static const int _infiniteOffset = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: _infiniteOffset,
    );
    _currentPage = _infiniteOffset.toDouble();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  int _getWrappedIndex(int index) {
    return index % widget.items.length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final currentIndex = _currentPage.floor();
          final visibleRange = 3;

          final indices = List.generate(
            visibleRange * 2 + 1,
            (index) => currentIndex - visibleRange + index,
          );

          indices.sort((a, b) {
            final aDiff = (a - _currentPage).abs();
            final bDiff = (b - _currentPage).abs();

            if (aDiff == bDiff) {
              return a > _currentPage ? -1 : 1;
            }
            return bDiff.compareTo(aDiff);
          });

          return Stack(
            alignment: Alignment.center,
            children: [
              ...indices.map((index) => Builder(
                    builder: (context) {
                      final wrappedIndex = _getWrappedIndex(index);
                      double difference = index - _currentPage;
                      double scale =
                          1 - (difference.abs() * (1 - widget.scaleFactor));

                      double translateX =
                          difference * widget.itemWidth * widget.spacingFactor;

                      int darkness =
                          (difference.abs() * 70).clamp(0, 255).toInt();

                      return Positioned(
                        left: constraints.maxWidth / 2 -
                            widget.itemWidth / 2 +
                            translateX,
                        child: Transform.scale(
                          scale: scale,
                          child: Stack(
                            children: [
                              Container(
                                width: widget.itemWidth,
                                height: widget.itemHeight,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: widget.items[wrappedIndex],
                              ),
                              Container(
                                width: widget.itemWidth,
                                height: widget.itemHeight,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(darkness),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: null, // null for infinite scrolling
                  itemBuilder: (context, index) => const SizedBox(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
