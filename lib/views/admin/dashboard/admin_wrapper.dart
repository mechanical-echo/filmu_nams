import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/dashboard.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_offers/manage_offers.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_payments/manage_payments.dart';
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
    if (index == 8) {
      _showLogoutDialog();
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  void _showLogoutDialog() {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Izlogoties"),
            content: Text("Vai tiešām vēlaties izlogoties?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Nē"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FirebaseAuth.instance.signOut();
                },
                child: Text("Jā"),
              ),
            ],
          );
        },
      );
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
        return Center(child: ManagePayments());
      case 8:
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

  Style get style => Style.of(context);

  bool get isExpanded => MediaQuery.of(context).size.width > 945;

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Row(
        spacing: 8,
        children: [
          IntrinsicWidth(
            child: Container(
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: style.cardDecoration,
              child: Column(
                spacing: 8,
                children: [
                  navigationItem("Sākums", Icons.dashboard, 0),
                  navigationItem("Sākuma elementi", Icons.image, 1),
                  navigationItem("Filmas", Icons.movie, 2),
                  navigationItem("Saraksts", Icons.schedule, 3),
                  navigationItem("Lietotāji", Icons.person, 4),
                  navigationItem("Piedāvājumi", Icons.local_offer, 5),
                  navigationItem("Promokodi", Icons.card_giftcard, 6),
                  navigationItem("Maksājumi", Icons.payment, 7),
                  navigationItem("Izlogoties", Icons.logout, 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20, right: 20, bottom: 20),
              child: body(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget navigationItem(String title, IconData icon, int index) {
    return InkWell(
      onTap: () => switchPage(index),
      child: AnimatedContainer(
        duration: Durations.short4,
        decoration: selectedIndex == index
            ? style.activeCardDecoration
            : style.cardDecoration,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        child: Row(
          spacing: 16,
          children: [
            Icon(icon),
            if (isExpanded) Text(title),
          ],
        ),
      ),
    );
  }
}
