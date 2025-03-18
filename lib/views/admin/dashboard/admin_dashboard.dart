import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/admin_side_bar/admin_side_bar.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/edit_carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPage = 0;
  String editingId = "";
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;

  void setCurrentPage(int newPageIndex) {
    setState(() {
      direction = newPageIndex > currentPage
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right;
      currentPage = newPageIndex;
    });
  }

  void setPageToEdit(int newPageIndex, String id) {
    setState(() {
      direction = newPageIndex > currentPage
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right;
      currentPage = newPageIndex;
      editingId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    List<Widget> pages = [
      ManageCarouselItems(action: setPageToEdit),
      Container(width: 50, height: 50, color: Colors.red),
      Placeholder(),
      Container(width: 50, height: 50, color: Colors.yellow),
      Placeholder(),
      Container(width: 50, height: 50, color: Colors.lightBlue),
      EditCarouselItem(id: editingId, action: setCurrentPage),
    ];

    return Background(
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
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
