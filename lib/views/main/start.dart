import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../resources/navigation.dart';

class Start extends StatefulWidget {
  const Start({super.key});
  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /**
      * Logotipa josla aplikācijas augšējā daļā
      */
      appBar: AppBar(
        titleSpacing: 0,
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        title: Container(
            clipBehavior: Clip.none,
            child: Column(
              children: [
                Container(height: 75),
                AppBar(
                  clipBehavior: Clip.none,
                  title: Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: SvgPicture.asset(
                      "assets/Logo.svg",
                      height: 120,
                    ),
                  ),
                  centerTitle: false,
                )
              ],
            )),
        centerTitle: false,
      ),

      /**
      * Navigācijas josla aplikācijas apakšā
      */
      bottomNavigationBar: BottomNavigationBar(
        items: navigationBarItems,
        selectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
        unselectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
        currentIndex: _selectedIndex,
        onTap: _onNavigationItemTapped,
      ),
    );
  }

  int _selectedIndex = 2;

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
