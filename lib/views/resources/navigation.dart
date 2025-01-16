import 'package:flutter/material.dart';

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
