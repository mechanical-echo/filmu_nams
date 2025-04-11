import 'package:flutter/material.dart';

class OverlappingCarousel extends StatefulWidget {
  final List<Widget> items;
  final double itemWidth;
  final double itemHeight;
  final double scaleFactor;
  final double horizontalSpace;
  final double spacingFactor;
  final Function(int)? onPageChanged;
  // Add new callback for vertical scroll with index
  final Function(int)? onVerticalScrollUp;

  const OverlappingCarousel({
    super.key,
    required this.items,
    required this.itemWidth,
    required this.itemHeight,
    this.scaleFactor = 0.8,
    this.horizontalSpace = 60,
    this.spacingFactor = 0.15,
    this.onPageChanged,
    this.onVerticalScrollUp, // New parameter
  });

  @override
  State<OverlappingCarousel> createState() => _OverlappingCarouselState();
}

class _OverlappingCarouselState extends State<OverlappingCarousel> {
  late PageController _pageController;
  double _currentPage = 0;
  static const int _infiniteOffset = 10000;

  // Variables to track vertical drag
  double _dragStartY = 0;
  double _dragEndY = 0;
  static const double _verticalDragThreshold = 50.0; // Minimum distance to consider a vertical swipe

  double get _viewportFraction {
    if (widget.items.length <= 1) return 1.0;
    if (widget.items.length == 2) return 0.7;
    return 0.6;
  }

  double get _dynamicSpacingFactor {
    if (widget.items.length <= 1) return 0.0;
    if (widget.items.length == 2) return 0.2;
    if (widget.items.length == 3) return widget.spacingFactor;
    return widget.spacingFactor *
        (1 - (widget.items.length - 0.5) * 0.1).clamp(0.5, 1.0);
  }

  double get _dynamicScale {
    if (widget.items.length <= 1) return 1.0;
    if (widget.items.length == 2) return 0.9;
    return widget.scaleFactor;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _infiniteOffset,
    );
    _currentPage = _infiniteOffset.toDouble();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
      if (widget.onPageChanged != null) {
        widget.onPageChanged!(_getWrappedIndex(_currentPage.round()));
      }
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
    return GestureDetector(
      // Handle vertical drag start
      onVerticalDragStart: (details) {
        _dragStartY = details.globalPosition.dy;
      },
      // Handle vertical drag end
      onVerticalDragEnd: (details) {
        // Check if swipe was from down to up (upward swipe)
        if (_dragStartY - _dragEndY > _verticalDragThreshold) {
          // Call the callback with the current active index if it exists
          if (widget.onVerticalScrollUp != null) {
            int currentIndex = _getWrappedIndex(_currentPage.round());
            widget.onVerticalScrollUp!(currentIndex);
          }
        }
      },
      // Update end position during drag
      onVerticalDragUpdate: (details) {
        _dragEndY = details.globalPosition.dy;
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.itemHeight,
        decoration: BoxDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final currentIndex = _currentPage.floor();
            final visibleRange =
            widget.items.length <= 3 ? widget.items.length - 1 : 3;

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
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ...indices.map(
                      (index) => Builder(
                    builder: (context) {
                      final wrappedIndex = _getWrappedIndex(index);
                      double difference = index - _currentPage;
                      double scale = 1 - (difference.abs() * (1 - _dynamicScale));

                      double translateX =
                          difference * widget.itemWidth * _dynamicSpacingFactor;

                      int darkness =
                      (difference.abs() * 170).clamp(0, 255).toInt();

                      return Positioned(
                        left: constraints.maxWidth / 2 -
                            widget.itemWidth / 2 +
                            translateX,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            -15 * (1 - difference.abs().clamp(0, 1)),
                          ),
                          child: Transform.rotate(
                            angle: difference * 0.1,
                            child: Transform.scale(
                              scale: scale,
                              child: Stack(
                                children: [
                                  Container(
                                    width: widget.itemWidth,
                                    height: widget.itemHeight,
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: null,
                    itemBuilder: (context, index) => const SizedBox(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}