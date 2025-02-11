import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class NavBar extends StatefulWidget {
  final Function(int) onPageChanged;
  final int currentIndex;

  const NavBar({
    super.key,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;

  @override
  void initState() {
    super.initState();

    _motionTabBarController = MotionTabBarController(
      initialIndex: 2,
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      controller: _motionTabBarController,

      // Pogas
      initialSelectedTab: "Sākums",
      labels: const [
        "Piedāvājumi",
        "Filmas",
        "Sākums",
        "Paziņojumi",
        "Profils"
      ],
      icons: const [
        Icons.percent,
        Icons.list,
        Icons.home,
        Icons.notifications,
        Icons.people_alt,
      ],

      // Jaunumu indikatora attēlošana uz navigācijas josla pogas
      badges: [
        null,
        null,
        null,
        const MotionBadgeWidget(
          isIndicator: true,
          show: true,
        ),
        null,
      ],

      // Stilizācija
      tabSize: 50,
      tabBarHeight: 75,
      textStyle: Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
      tabIconColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      tabIconSize: 30.0,
      tabIconSelectedSize: 34.0,
      tabSelectedColor: Theme.of(context).primaryColor,
      tabIconSelectedColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      tabBarColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,

      // Funkcionalitāte
      onTabItemSelected: (int value) {
        setState(() {
          _motionTabBarController?.index = value;
          widget.onPageChanged(value);
        });
      },
    );
  }
}
