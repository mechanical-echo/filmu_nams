import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/offer_model.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_offers/offer_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_offers/edit_offer_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';

class ManageOffers extends StatefulWidget {
  const ManageOffers({super.key});

  @override
  State<ManageOffers> createState() => _ManageOffersState();
}

class _ManageOffersState extends State<ManageOffers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _offerSubscription;

  List<OfferModel> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToOfferChanges();
  }

  void listenToOfferChanges() {
    _offerSubscription =
        _firestore.collection('offers').snapshots().listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => OfferModel.fromMapAsync(doc.data(), doc.id),
      );

      try {
        final items = await Future.wait(futures.toList());

        setState(() {
          offers = items;
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Error processing offers: $e');
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (e) {
      debugPrint('Error listening to offer changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _offerSubscription?.cancel();
    super.dispose();
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditOfferDialog();
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
      height: 100,
      count: offers.length,
      isLoading: isLoading,
      itemGenerator: (index) => OfferCard(
        data: offers[index],
        onEdit: (id) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return EditOfferDialog(id: id);
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
        },
      ),
      title: "Piedāvājumi",
      onCreate: showAddDialog,
    );
  }
}
