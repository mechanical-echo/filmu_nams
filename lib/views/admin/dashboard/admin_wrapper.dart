import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/manage_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdminWrapper extends StatefulWidget {
  const AdminWrapper({super.key});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  int selectedIndex = 0;
  bool expanded = false;

  ContextTheme get theme => ContextTheme.of(context);

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void expand() {
    setState(() {
      expanded = true;
    });
  }

  void shrink() {
    setState(() {
      expanded = false;
    });
  }

  Widget body(int index) {
    switch (index) {
      case 0:
        return Center(child: Text("Welcome to the Dashboard"));
      case 1:
        return Center(child: ManageCarouselItems());
      case 2:
        return Center(child: ManageMovies());
      case 3:
        return Center(child: ManageUsers());
      case 4:
        return Center(child: Text("Offers section"));
      case 5:
        return Center(child: Text("Payments section"));
      case 6:
        FirebaseAuth.instance.signOut();
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white12,
            size: 100,
          ),
        );
      default:
        return Center(child: Text("Unknown section"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 100,
                top: 50,
                right: 20,
                bottom: 50,
              ),
              child: body(selectedIndex)),
        ),
        IntrinsicWidth(
          child: MouseRegion(
            onEnter: (event) => expand(),
            onExit: (event) => shrink(),
            child: NavigationRail(
              extended: expanded,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text("Sākums"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.screen_lock_landscape),
                  label: Text("Carousel"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.movie),
                  label: Text("Filmas"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text("Lietotāji"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.percent),
                  label: Text("Piedāvājumi"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.payments),
                  label: Text("Maksājumi"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text("Izlogoties"),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: switchPage,
            ),
          ),
        ),
      ],
    );
  }
}
