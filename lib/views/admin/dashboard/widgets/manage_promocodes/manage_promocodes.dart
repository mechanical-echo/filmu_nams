import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/promocode_model.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_promocodes/promocode_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_promocodes/edit_promocode_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';

class ManagePromocodes extends StatefulWidget {
  const ManagePromocodes({super.key});

  @override
  State<ManagePromocodes> createState() => _ManagePromocodesState();
}

class _ManagePromocodesState extends State<ManagePromocodes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _promocodeSubscription;

  List<PromocodeModel> promocodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToPromocodeChanges();
  }

  void listenToPromocodeChanges() {
    _promocodeSubscription = _firestore
        .collection('promocodes')
        .snapshots()
        .listen((snapshot) async {
      final items = snapshot.docs
          .map((doc) => PromocodeModel.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        promocodes = items;
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to promocode changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _promocodeSubscription?.cancel();
    super.dispose();
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditPromocodeDialog();
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
      height: 50,
      count: promocodes.length,
      isLoading: isLoading,
      itemGenerator: (index) => PromocodeCard(
        data: promocodes[index],
        onEdit: (id) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return EditPromocodeDialog(id: id);
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
      title: "Promokodi",
      onCreate: showAddDialog,
    );
  }
}
