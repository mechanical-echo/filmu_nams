import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableView extends StatefulWidget {
  const ExpandableView({super.key, required this.child, required this.title});
  final Widget child;
  final String title;

  @override
  State<ExpandableView> createState() => _ExpandableViewState();
}

class _ExpandableViewState extends State<ExpandableView> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 450),
      curve: Curves.linearToEaseOut,
      child: Container(
        width: 800,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withAlpha(50)),
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    style: FilledButton.styleFrom(
                      fixedSize: Size(40, 40),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) widget.child,
          ],
        ),
      ),
    );
  }
}
