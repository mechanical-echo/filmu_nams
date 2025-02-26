import 'package:filmu_nams/views/admin/dashboard/widgets/expandable_view/expandable_view.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/homepage_carousel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                spacing: 20,
                children: [
                  HomepageCarousel(),

                  // Placeholders
                  ExpandableView(title: "Filmas", child: Placeholder()),
                  ExpandableView(title: "Lietotāji", child: Placeholder()),
                  ExpandableView(title: "Piedāvājumi", child: Placeholder()),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FilledButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text("Izlogoties"),
            ),
          ),
        ],
      ),
    );
  }
}
