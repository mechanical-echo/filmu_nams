import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:pattern_background/pattern_background.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class Start extends StatefulWidget {
  const Start({super.key});
  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> with TickerProviderStateMixin {
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,

      /**
       * Aplikācijas augšēja daļa
       */
      appBar: AppBar(
        titleSpacing: 0,
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Container(
            clipBehavior: Clip.none,
            child: Column(
              children: [
                Container(height: 75), //tukšā vieta virs logotipa

                // Josla ar logotipu
                AppBar(
                  clipBehavior: Clip.none,
                  title: Row(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SvgPicture.asset(
                          "assets/Logo.svg",
                          height: 120,
                        ),
                      ),

                      // Šodienas datums
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: BorderedText(
                          strokeWidth: 5.0,
                          strokeColor: Colors.black,
                          child: Text(
                            DateFormat('E dd.MM.', 'lv').format(DateTime.now()),
                            style: GoogleFonts.kodchasan(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                )
              ],
            )),
      ),

      /**
       * Galvena daļa
       * Container un CustomPaint ir nepieciešamas fona attēlošanai
       */
      body: Stack(
        children: [
          // Gradients
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 34, 5, 6), Colors.black],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),

          // Melnie punkti
          CustomPaint(
              size: Size(width, height),
              painter: DotPainter(
                dotColor: Colors.black,
                dotRadius: 4,
                spacing: 10,
              )),
        ],
      ),

      /**
       * Navigācijas josla
       */
      bottomNavigationBar: MotionTabBar(
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
        textStyle:
            Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
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
          });
        },
      ),
    );
  }
}
