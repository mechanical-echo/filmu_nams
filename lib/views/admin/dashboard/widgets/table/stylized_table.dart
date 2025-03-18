import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';

class StylizedTable extends StatelessWidget {
  const StylizedTable({super.key, required this.children});
  final List<TableRow> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(
        minWidth: 800,
        maxWidth: 1200,
      ),
      decoration: classicDecorationDark,
      child: Container(
        decoration: classicDecorationSharp,
        child: Table(
          border: TableBorder.all(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          children: children,
        ),
      ),
    );
  }
}
