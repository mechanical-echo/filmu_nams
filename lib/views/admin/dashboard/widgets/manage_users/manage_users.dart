import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_users/user_card/user_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({
    super.key,
    required this.action,
  });

  final Function(int, String) action;

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
        Container(
          constraints: BoxConstraints(
            maxWidth: 1300,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: classicDecorationSharper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Text("Lietotāji", style: header1),
              ),
              Container(
                decoration: classicDecorationSharper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Text("Kopā: ${users.length}", style: header1),
              ),
            ],
          ),
        ),
        AnimatedSize(
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 700,
              maxWidth: 1300,
            ),
            decoration: classicDecorationDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: smokeyWhite,
                      size: 100,
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 20,
                    children: List.generate(
                        users.length, (index) => generateCard(index)),
                  ),
          ),
        ),
        SizedBox(),
        IntrinsicWidth(
          child: StylizedButton(
            action: () => widget.action(9, ""),
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
          widget.action(8, userId);
        },
      ),
    );
  }
}
