import 'package:flutter/material.dart';
import 'package:json_theme_plus/json_theme_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(MainApp(
    theme: theme,
  ));
}

const double bottomNavigationBarTopPadding = 10;

BottomNavigationBarItem offersDestination = BottomNavigationBarItem(
  icon: Container(
      padding: EdgeInsets.only(top: bottomNavigationBarTopPadding),
      child: Icon(Icons.percent)),
  label: 'Piedāvājumi',
);

BottomNavigationBarItem moviesDestination = BottomNavigationBarItem(
  icon: Container(
      padding: EdgeInsets.only(top: bottomNavigationBarTopPadding),
      child: Icon(Icons.list)),
  label: 'Filmas',
);

BottomNavigationBarItem homeDestination = BottomNavigationBarItem(
  icon: Container(
      padding: EdgeInsets.only(top: bottomNavigationBarTopPadding),
      child: Icon(Icons.home_outlined)),
  label: 'Sākums',
);

BottomNavigationBarItem notificationsDestination = BottomNavigationBarItem(
  icon: Badge(
      label: Text('2'),
      child: Container(
          padding: EdgeInsets.only(top: bottomNavigationBarTopPadding),
          child: Icon(Icons.notifications_sharp))),
  label: 'Notifikācijas',
);

BottomNavigationBarItem profileDestination = BottomNavigationBarItem(
  icon: Container(
      padding: EdgeInsets.only(top: bottomNavigationBarTopPadding),
      child: Icon(Icons.person)),
  label: 'Profils',
);

List<BottomNavigationBarItem> navigationBarItems = <BottomNavigationBarItem>[
  offersDestination,
  moviesDestination,
  homeDestination,
  notificationsDestination,
  profileDestination,
];

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: navigationBarItems,
          currentIndex: 2,
          selectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
          unselectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
        ),
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
      ),
    );
  }
}
