import 'package:filmu_nams/views/main/home/home.dart';
import 'package:filmu_nams/views/main/profile/profile.dart';
import 'package:filmu_nams/views/resources/background.dart';
import 'package:filmu_nams/views/resources/carousel_switch.dart';
import 'package:filmu_nams/views/resources/logo.dart';
import 'package:filmu_nams/views/resources/navigation_bar.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with TickerProviderStateMixin {
  int _currentPageIndex = 2;
  int _previousPageIndex = 2;

  void _onPageChanged(int index) {
    setState(() {
      _previousPageIndex = _currentPageIndex;
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Placeholder(),
      Placeholder(),
      Home(),
      Placeholder(),
      Profile(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: Logo(),
      ),
      body: Background(
        child: CarouselSwitch(
          direction: _currentPageIndex > _previousPageIndex
              ? CarouselSwitchDirection.left
              : CarouselSwitchDirection.right,
          child: pages[_currentPageIndex],
        ),
      ),
      bottomNavigationBar: NavBar(
        onPageChanged: _onPageChanged,
        currentIndex: _currentPageIndex,
      ),
    );
  }
}
