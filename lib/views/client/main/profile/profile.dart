import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/client/main/profile/payments/payment_history_view.dart';
import 'package:filmu_nams/views/client/main/profile/profile_view.dart';
import 'package:filmu_nams/views/client/main/profile/qr_scanner.dart';
import 'package:filmu_nams/views/client/main/profile/settings.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/tickets_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  int currentView = 0;
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      UserController userController = UserController();
      UserModel? currentUser = await userController.getCurrentUserModel();
      if (currentUser != null && currentUser.role == UserRolesEnum.admin) {
        setState(() {
          isAdmin = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking user role: $e');
    }
  }

  void switchView(int viewIndex) {
    setState(() {
      direction = viewIndex == 0
          ? CarouselSwitchDirection.right
          : CarouselSwitchDirection.left;
      currentView = viewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      profileMenu(context),
      ProfileView(onPressed: () => switchView(0)),
    ];

    return Center(
      child: CarouselSwitch(
        alignment: AlignmentDirectional.center,
        direction: direction,
        child: KeyedSubtree(
          key: ValueKey(currentView),
          child: views[currentView],
        ),
      ),
    );
  }

  Widget profileMenu(BuildContext context) {
    final theme = Style.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              image(),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                      Colors.black.withAlpha(230),
                    ],
                    stops: const [0.0, 0.3, 0.9, 1],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  user!.displayName!,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withAlpha(229),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Divider(
            color: theme.contrast.withAlpha(25),
            height: 1,
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            "Profils",
            Icons.person_outline,
            () => switchView(1),
          ),
          _buildMenuButton(
            "Biļetes",
            Icons.confirmation_number_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketsView()),
              );
            },
          ),
          _buildMenuButton(
            "Maksājumi",
            Icons.payment_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentHistoryView(),
                ),
              );
            },
          ),
          if (isAdmin)
            _buildMenuButton(
              "QR Skenēšana",
              Icons.qr_code_scanner,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QRScannerView()),
                );
              },
            ),
          _buildMenuButton(
            "Iestatījumi",
            Icons.settings_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Container image() {
    final theme = Style.of(context);
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.hardEdge,
      child: user!.photoURL != null
          ? CachedNetworkImage(
              imageUrl: user!.photoURL!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    size: 50,
                    color: Theme.of(context).focusColor,
                  ),
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: 85,
              color: theme.contrast,
            ),
    );
  }

  Widget _buildMenuButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final style = Style.of(context);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: style.cardDecoration,
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor.withAlpha(178),
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: style.bodyLarge,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: style.contrast.withAlpha(125),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
