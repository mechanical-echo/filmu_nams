import 'package:flutter/material.dart';
import 'package:json_theme_plus/json_theme_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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
        body: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            padding: EdgeInsets.all(25),
            child: Text("test"),
          ),
        ),
      ),
    );
  }
}
