import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/notification_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.onPageChanged,
    required this.currentIndex,
  });

  final Function(int) onPageChanged;
  final int currentIndex;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  List<NotificationModel> notifications = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _notificationFetchSubscription;

  Future<void> fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    final userRef = _firestore.collection('users').doc(user!.uid);

    _notificationFetchSubscription = _firestore
        .collection('notifications')
        .where('user', isEqualTo: userRef)
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .listen((snapshot) async {
      final notificaitonDocs = snapshot.docs.map(
        (doc) => NotificationModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(notificaitonDocs.toList());

      setState(() {
        notifications = items;
      });
    }, onError: (e) {
      debugPrint('Error listening to notification changes: $e');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _notificationFetchSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.percent,
      Icons.list,
      Icons.home,
      Icons.notifications,
      Icons.person,
    ];

    List<String> labels = [
      'Piedāvājumi',
      'Saraksts',
      'Sākums',
      'Paziņojumi',
      'Profils',
    ];

    final style = Style.of(context);
    final theme = Theme.of(context);

    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: style.roundCardDecoration,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    icons.length,
                    (index) {
                      final isSelected = widget.currentIndex == index;
                      final wasSelected = _previousIndex == index;

                      Animation<double> animation;
                      if (isSelected) {
                        animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Cubic(1, 0, 0, 1),
                          ),
                        );
                      } else if (wasSelected) {
                        animation = Tween<double>(begin: 1.0, end: 0.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Cubic(1, 0, 0, 1),
                          ),
                        );
                      } else {
                        animation = const AlwaysStoppedAnimation<double>(0.0);
                      }

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final flexFactor = 1 + animation.value;

                          return Flexible(
                            flex: (flexFactor * 10).round(),
                            child: GestureDetector(
                              onTap: () => widget.onPageChanged(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4 + (animation.value * 8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.0 + (0.1 * animation.value),
                                      child: icons[index] ==
                                                  Icons.notifications &&
                                              notifications.isNotEmpty
                                          ? Badge.count(
                                              count: notifications.length,
                                              child: Icon(
                                                icons[index],
                                                color: Color.lerp(
                                                  style.contrast.withAlpha(125),
                                                  style.primary,
                                                  0.5 + (0.5 * animation.value),
                                                ),
                                                size: 28,
                                              ),
                                            )
                                          : Icon(
                                              icons[index],
                                              color: Color.lerp(
                                                theme.colorScheme.onSurface
                                                    .withAlpha(125),
                                                theme.primaryColor,
                                                0.5 + (0.5 * animation.value),
                                              ),
                                              size: 28,
                                            ),
                                    ),
                                    ClipRect(
                                      child: SizedBox(
                                        height: animation.value * 20,
                                        child: Opacity(
                                          opacity: animation.value,
                                          child: Transform.translate(
                                            offset: Offset(
                                                0, 5 * (1 - animation.value)),
                                            child: Text(
                                              labels[index],
                                              style: GoogleFonts.poppins(
                                                color: theme.primaryColor,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
