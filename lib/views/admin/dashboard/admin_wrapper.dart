import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/dashboard.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_offers/manage_offers.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_promocodes/manage_promocodes.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/manage_schedule.dart';
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

  Style get theme => Style.of(context);

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget body(int index) {
    switch (index) {
      case 0:
        return Center(child: Dashboard());
      case 1:
        return Center(child: ManageCarouselItems());
      case 2:
        return Center(child: ManageMovies());
      case 3:
        return Center(child: ManageSchedule());
      case 4:
        return Center(child: ManageUsers());
      case 5:
        return Center(child: ManageOffers());
      case 6:
        return Center(child: ManagePromocodes());
      case 7:
        return Center(child: Text("Payments section"));
      case 8:
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isExpanded = screenWidth > 900;
    final leftPadding = isExpanded ? 280.0 : 100.0;

    return Stack(
      children: [
        Background(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: leftPadding,
              top: 50,
              right: 20,
              bottom: 50,
            ),
            child: body(selectedIndex),
          ),
        ),
        IntrinsicWidth(
          child: NavigationRail(
            extended: isExpanded,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text("Sākums"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.screen_lock_landscape),
                label: Text("Sākuma lapas elementi"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.movie),
                label: Text("Filmas"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text("Saraksts"),
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
                icon: Icon(Icons.local_offer_outlined),
                label: Text("Promokodi"),
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
      ],
    );
  }
}
