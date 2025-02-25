import 'package:flutter/material.dart';

class StylizedTable extends StatelessWidget {
  const StylizedTable({super.key, required this.children});
  final List<TableRow> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.all(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        children: children,
      ),
    );
  }
}
