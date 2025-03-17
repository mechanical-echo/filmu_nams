import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/admin_side_bar/admin_side_bar.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/homepage_carousel.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPage = 0;
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;

  void setCurrentPage(int newPageIndex) {
    setState(() {
      direction = newPageIndex > currentPage
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right;
      currentPage = newPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    List<Widget> pages = [
      HomepageCarousel(),
      Container(width: 50, height: 50, color: Colors.red),
      Placeholder(),
      Container(width: 50, height: 50, color: Colors.yellow),
      Placeholder(),
      Container(width: 50, height: 50, color: Colors.lightBlue),
    ];

    return Background(
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: CarouselSwitch(
                  direction: direction,
                  child: pages[currentPage],
                ),
              ),
            ),
          ),
          AdminSideBar(
              height: height, action: setCurrentPage, activePage: currentPage),
        ],
      ),
    );
  }
}
