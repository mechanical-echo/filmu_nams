import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:flutter/material.dart';

class FoldableDescription extends StatefulWidget {
  const FoldableDescription({
    super.key,
    required this.data,
  });

  final MovieModel data;

  @override
  State<FoldableDescription> createState() => _FoldableDescriptionState();
}

class _FoldableDescriptionState extends State<FoldableDescription>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _clipAnimation;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _clipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDescription() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _animationController.forward() : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDescription,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _clipAnimation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.only(
                  left: 35,
                  right: 35,
                  top: 15,
                  bottom: 35,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  border: bottomBorder,
                  boxShadow: cardShadow,
                  color: red002,
                ),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1 - (0.78 * (1 - _clipAnimation.value)),
                    child: Text(
                      widget.data.description,
                      style: bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 35,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: red002,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: cardShadow,
                border: bottomBorder,
              ),
              width: 80,
              height: 30,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value *
                              (270 - 90) *
                              3.1415927 /
                              180 +
                          (90 * 3.1415927 / 180),
                      child: Icon(
                        Icons.chevron_right,
                        size: 30,
                        color: Colors.white,
                      ),
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
