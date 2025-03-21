import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/admin_side_bar/admin_side_bar.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/edit_carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/add_user.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/edit_user.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/manage_users.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPage = 3;
  String editingId = "";
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;
  bool isSidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void setCurrentPage(int newPageIndex) {
    setState(() {
      direction = newPageIndex > currentPage
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right;
      currentPage = newPageIndex;
      // Close drawer when changing pages on mobile
      if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
    });
  }

  void setPageToEdit(int newPageIndex, String id) {
    setState(() {
      direction = newPageIndex > currentPage
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right;
      currentPage = newPageIndex;
      editingId = id;
      // Close drawer when changing pages on mobile
      if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
    });
  }

  void toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isSmallScreen = width < 1200;

    List<Widget> pages = [
      ManageCarouselItems(action: setPageToEdit),
      ManageMovies(action: setPageToEdit),
      Container(width: 50, height: 50, color: Colors.red),
      ManageUsers(action: setPageToEdit),
      Container(width: 50, height: 50, color: Colors.yellow),
      Placeholder(),
      Container(width: 50, height: 50, color: Colors.lightBlue),
      EditCarouselItem(id: editingId, action: setCurrentPage),
      EditUser(id: editingId, action: setCurrentPage),
      AddUser(action: setCurrentPage),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: isSmallScreen
          ? Drawer(
              child: AdminSideBar(
                height: height,
                action: setCurrentPage,
                activePage: currentPage,
              ),
            )
          : null,
      body: Background(
        child: Row(
          children: [
            if (!isSmallScreen && isSidebarVisible)
              AdminSideBar(
                height: height,
                action: setCurrentPage,
                activePage: currentPage,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSmallScreen)
                    IntrinsicWidth(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: classicDecorationDarkSharper,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              color: smokeyWhite,
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CarouselSwitch(
                          direction: direction,
                          child: pages[currentPage],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
