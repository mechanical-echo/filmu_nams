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
      child: IntrinsicWidth(
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width - 40, // Account for padding
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withAlpha(50)),
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntrinsicWidth(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 100),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(50, 30),
                        maximumSize: const Size(50, 30),
                        padding: EdgeInsets.zero,
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
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: widget.child,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
