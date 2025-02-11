import 'package:filmu_nams/views/client/main/home/home.dart';
import 'package:filmu_nams/views/client/main/profile/profile.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/decorations/logo.dart';
import 'package:filmu_nams/assets/navigation_bar.dart';
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
    return Base(
      body: Body(
        currentPageIndex: _currentPageIndex,
        previousPageIndex: _previousPageIndex,
      ),
      bottomNavigationBar: NavigationBar(
        currentPageIndex: _currentPageIndex,
        onPageChanged: _onPageChanged,
      ),
    );
  }
}

class Base extends StatelessWidget {
  const Base({
    super.key,
    required this.body,
    required this.bottomNavigationBar,
  });

  final Widget body;
  final Widget bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: Logo(),
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    super.key,
    required this.currentPageIndex,
    required this.previousPageIndex,
  });

  final int currentPageIndex;
  final int previousPageIndex;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Placeholder(),
      Placeholder(),
      Home(),
      Placeholder(),
      Profile(),
    ];

    return Background(
      child: CarouselSwitch(
        direction: widget.currentPageIndex > widget.previousPageIndex
            ? CarouselSwitchDirection.left
            : CarouselSwitchDirection.right,
        child: pages[widget.currentPageIndex],
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.currentPageIndex,
    required this.onPageChanged,
  });

  final int currentPageIndex;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return NavBar(
      onPageChanged: onPageChanged,
      currentIndex: currentPageIndex,
    );
  }
}
