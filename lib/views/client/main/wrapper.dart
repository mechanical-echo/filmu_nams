import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/client/main/home/home.dart';
import 'package:filmu_nams/views/client/main/offers/offer_list_view.dart';
import 'package:filmu_nams/views/client/main/notifications/notifications.dart';
import 'package:filmu_nams/views/client/main/profile/profile.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/navigation_bar.dart';
import 'package:filmu_nams/views/client/main/schedule/schedule.dart';
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
    final theme = Style.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: Background(
              child: SizedBox.expand(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.isDark
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.0),
                  theme.isDark ? Colors.black87 : Colors.white,
                ],
                stops: const [0.5, 1],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: body,
                ),
              ),
              bottomNavigationBar,
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
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
      OffersList(),
      ScheduleAndMovies(),
      Home(),
      Notifications(),
      Profile(),
    ];

    return CarouselSwitch(
      direction: widget.currentPageIndex > widget.previousPageIndex
          ? CarouselSwitchDirection.left
          : CarouselSwitchDirection.right,
      child: pages[widget.currentPageIndex],
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
