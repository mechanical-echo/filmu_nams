import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/carousel_item_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';

class ManageCarouselItems extends StatefulWidget {
  const ManageCarouselItems({super.key});

  @override
  State<ManageCarouselItems> createState() => _ManageCarouselItemsState();
}

class _ManageCarouselItemsState extends State<ManageCarouselItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _carouselSubscription;

  List<CarouselItemModel> carouselItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToCarouselChanges();
  }

  void listenToCarouselChanges() {
    _carouselSubscription = _firestore
        .collection(MovieController.carouselCollection)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => CarouselItemModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        carouselItems = items;
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to carousel changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _carouselSubscription?.cancel();
    super.dispose();
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditCarouselItemDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScreen(
      count: carouselItems.length,
      isLoading: isLoading,
      itemGenerator: generateCards(),
      title: "Sākuma lapas elementi",
      onCreate: showAddDialog,
    );
  }

  generateCards() {
    return (index) => CarouselItemCard(
          data: carouselItems[index],
        );
  }
}
