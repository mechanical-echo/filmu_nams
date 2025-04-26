import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/user_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/edit_user_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _userSubscription;

  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  String? currentUserId;
  bool isLoading = true;
  String currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    listenToUserChanges();
  }

  void listenToUserChanges() {
    _userSubscription = _firestore
        .collection(UserController.usersPath)
        .snapshots()
        .listen((snapshot) async {
      final items = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        users = items;
        _applyFilter();
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to user changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  void _applyFilter() {
    setState(() {
      if (currentFilter == 'all') {
        filteredUsers = List.from(users);
      } else {
        filteredUsers =
            users.where((user) => user.role == currentFilter).toList();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditUserDialog();
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
      subHeader: _buildFilterBar(),
      height: 98,
      count: filteredUsers.length,
      isLoading: isLoading,
      itemGenerator: (index) => UserCard(
        data: filteredUsers[index],
        isCurrentUser: filteredUsers[index].id == currentUserId,
        onEdit: (id) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return EditUserDialog(id: id);
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
      title: "Lietotāji${_getFilterSuffix()}",
      onCreate: showAddDialog,
    );
  }

  String _getFilterSuffix() {
    if (currentFilter == 'all') {
      return "";
    } else if (currentFilter == 'admin') {
      return " (tikai administratori)";
    } else {
      return " (tikai lietotāji)";
    }
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (filteredUsers.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "Nav lietotāju ar atlasītajām lomām",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<String>(
              value: currentFilter,
              underline: SizedBox(),
              icon: Icon(Icons.filter_list),
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentFilter = newValue;
                    _applyFilter();
                  });
                }
              },
              items: <String>['all', 'admin', 'user']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'all'
                      ? 'Visi lietotāji'
                      : value == 'admin'
                          ? 'Tikai administratori'
                          : 'Tikai lietotāji'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
