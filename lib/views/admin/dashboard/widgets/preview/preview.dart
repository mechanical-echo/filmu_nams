import 'package:filmu_nams/views/client/client.dart';
import 'package:flutter/material.dart';

class Preview extends StatefulWidget {
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 950,
      decoration: BoxDecoration(
        color: Colors.white24,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClientApp(),
    );
  }
}
