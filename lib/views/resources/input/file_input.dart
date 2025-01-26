import 'package:flutter/material.dart';

class FileInput extends StatelessWidget {
  final List<double> margin;
  final String? hintText;
  final String? labelText;
  const FileInput(
      {super.key, required this.margin, this.hintText, this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: margin[0],
        right: margin[1],
        bottom: margin[2],
        left: margin[3],
      ),
      child: Container(
        decoration: BoxDecoration(),
      ),
    );
  }
}
