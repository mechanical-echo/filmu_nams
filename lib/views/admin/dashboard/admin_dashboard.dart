import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/admin_side_bar/admin_side_bar.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/edit_carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/add_schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/edit_schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/manage_schedule.dart';
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
  String currentPage = "mng_carousel";
  String editingId = "";
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;
  bool isSidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void setCurrentPage(String pageId) {
    setState(() {
      currentPage = pageId;
      hideDrawer();
    });
  }

  void setPageToEdit(String pageId, String id) {
    setState(() {
      currentPage = pageId;
      editingId = id;
      hideDrawer();
    });
  }

  void toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  void hideDrawer() {
    setState(() {
      if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isSmallScreen = width < 1200;

    Map<String, Widget> views = {
      // manage views
      "mng_carousel": ManageCarouselItems(action: setPageToEdit),
      "mng_movies": ManageMovies(action: setPageToEdit),
      "mng_schedule": ManageSchedule(action: setPageToEdit),
      "mng_users": ManageUsers(action: setPageToEdit),
      "mng_offers": Container(width: 50, height: 50, color: Colors.yellow),
      "mng_promos": Placeholder(),
      "mng_payments": Container(width: 50, height: 50, color: Colors.lightBlue),

      // edit views
      "edit_carousel": EditCarouselItem(id: editingId, action: setCurrentPage),
      "edit_movie": EditMovie(id: editingId, action: setCurrentPage),
      "edit_schedule": EditSchedule(id: editingId, action: setCurrentPage),
      "edit_user": EditUser(id: editingId, action: setCurrentPage),

      // add views
      "add_user": AddUser(action: setCurrentPage),
      "add_schedule": AddSchedule(action: setCurrentPage),
    };

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
                          child: views[currentPage]!,
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
