import 'package:filmu_nams/views/client/client.dart';
import 'package:flutter/material.dart';

class PreviewMobileApp extends StatefulWidget {
  const PreviewMobileApp({super.key});

  @override
  State<PreviewMobileApp> createState() => _PreviewMobileAppState();
}

class _PreviewMobileAppState extends State<PreviewMobileApp> {
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
