import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/user_card/user_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({
    super.key,
    required this.action,
  });

  final Function(String, String) action;

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsersFromFirebase();
  }

  Future<void> fetchUsersFromFirebase() async {
    try {
      final response = await UserController().getAllUsers();
      setState(() {
        users = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ManageScreen(
          count: users.length,
          isLoading: isLoading,
          itemGenerator: generateCard,
          title: "Lietotāji",
        ),
        IntrinsicWidth(
          child: StylizedButton(
            action: () => widget.action("add_user", ""),
            title: "Pievienot lietotāju",
            icon: Icons.person_add,
          ),
        ),
      ],
    );
  }

  Widget generateCard(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: classicDecorationSharp,
      child: UserCard(
        data: users[index],
        onEdit: (userId) {
          widget.action("edit_user", userId);
        },
      ),
    );
  }
}
