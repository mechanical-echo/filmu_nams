import 'package:filmu_nams/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleDescription,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(
                  'Apraksts',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                RotationTransition(
                  turns: _rotationAnimation,
                  child: const Icon(
                    Icons.expand_more,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _heightAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              widget.data.description,
              style: GoogleFonts.poppins(
                color: Colors.white.withAlpha(205),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
