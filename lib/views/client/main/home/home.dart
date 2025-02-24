import 'package:filmu_nams/assets/decorations/stylized_carousel.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height * 0.3,
            child: StylizedCarousel(
              items: List.generate(
                5,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                  ),
                  alignment: Alignment.center,
                  child: Text("Item $index",
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
