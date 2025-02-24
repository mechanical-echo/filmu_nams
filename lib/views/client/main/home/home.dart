import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> carouselItems = List.generate(
    5,
    (index) => Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha(127)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Item ${index + 1}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OverlappingCarousel(
            items: carouselItems,
            itemWidth: width * 0.65,
            itemHeight: height * 0.4,
            scaleFactor: 0.85,
            horizontalSpace: 10,
            spacingFactor: 0.3,
          ),
        ],
      ),
    );
  }
}
