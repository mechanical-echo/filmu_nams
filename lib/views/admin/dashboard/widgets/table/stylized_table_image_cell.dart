import 'package:flutter/material.dart';

class StylizedTableImageCell extends StatelessWidget {
  const StylizedTableImageCell({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Image.network(
        imageUrl,
        height: 100,
      ),
    );
  }
}
