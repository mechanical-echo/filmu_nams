import 'package:filmu_nams/assets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSideBar extends StatelessWidget {
  const AdminSideBar({
    super.key,
    required this.height,
    required this.action,
    required this.activePage,
  });

  final double height;
  final Function(String) action;
  final String activePage;

  @override
  Widget build(BuildContext context) {
    final Uri url = Uri.parse(
        'https://console.firebase.google.com/project/filmu-nams/overview');

    Future<void> openLink() async {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    void logout() {
      FirebaseAuth.instance.signOut();
    }

    bool isDrawer = Scaffold.of(context).hasDrawer;
    double sidebarWidth = isDrawer ? double.infinity : 300;

    return Container(
      height: height,
      width: sidebarWidth,
      margin: isDrawer
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: isDrawer ? null : classicDecorationDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          AdminLogo(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: smokeyWhite.withAlpha(100),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminSideBarButton(
                    title: 'Sākuma lapas elementi',
                    icon: Icons.home,
                    action: () => action("mng_carousel"),
                    active: activePage == "mng_carousel",
                  ),
                  AdminSideBarButton(
                    title: 'Filmas',
                    icon: Icons.movie,
                    action: () => action("mng_movies"),
                    active: activePage == "mng_movies",
                  ),
                  AdminSideBarButton(
                    title: 'Saraksts',
                    icon: Icons.list,
                    action: () => action("mng_schedule"),
                    active: activePage == "mng_schedule",
                  ),
                  AdminSideBarButton(
                    title: 'Lietotāji',
                    icon: Icons.people,
                    action: () => action("mng_users"),
                    active: activePage == "mng_users",
                  ),
                  AdminSideBarButton(
                    title: 'Piedāvājumi',
                    icon: Icons.percent,
                    action: () => action("mng_offers"),
                    active: activePage == "mng_offers",
                  ),
                  AdminSideBarButton(
                    title: 'Promokodi',
                    icon: Icons.abc,
                    action: () => action("mng_promos"),
                    active: activePage == "mng_promos",
                  ),
                  AdminSideBarButton(
                    title: 'Maksājumi',
                    icon: Icons.payments,
                    action: () => action("mng_payments"),
                    active: activePage == "mng_payments",
                  ),
                  AdminSideBarButton(
                    title: 'Firebase',
                    icon: Icons.local_fire_department_sharp,
                    action: openLink,
                  ),
                ],
              ),
            ),
          ),
          AdminSideBarButton(
            title: 'Izlogoties',
            icon: Icons.logout,
            action: logout,
          )
        ],
      ),
    );
  }
}

class AdminLogo extends StatelessWidget {
  const AdminLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: classicDecorationWhiteSharper,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_filter,
                color: red001,
                size: 25,
              ),
              const SizedBox(width: 8),
              Text(
                "Filmu Nams",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: red001,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Text(
            "Administrācijas panelis",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: red002,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdminSideBarButton extends StatefulWidget {
  const AdminSideBarButton({
    super.key,
    required this.title,
    required this.icon,
    required this.action,
    this.active = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback action;
  final bool active;

  @override
  State<AdminSideBarButton> createState() => _AdminSideBarButtonState();
}

class _AdminSideBarButtonState extends State<AdminSideBarButton> {
  double indent = 0;

  void setIndent() {
    setState(() {
      indent = 20;
    });
  }

  void removeIndent() {
    setState(() {
      indent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDrawer = Scaffold.of(context).hasDrawer;

    if (isDrawer) {
      return ListTile(
        leading: Icon(
          widget.icon,
          size: 25,
          color: red001,
        ),
        title: Text(
          widget.title,
          style: bodyMediumRed,
        ),
        selected: widget.active,
        onTap: widget.action,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: indent + (widget.active ? 20 : 0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) => setIndent(),
              onExit: (event) => removeIndent(),
              child: GestureDetector(
                onTap: widget.action,
                child: AnimatedContainer(
                  width: 280,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: classicDecorationWhiteSharper,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Icon(
                        widget.icon,
                        size: 25,
                        color: red001,
                      ),
                      SizedBox(
                        width: 500,
                        child: Text(
                          widget.title,
                          style: bodyMediumRed,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
