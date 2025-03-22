import 'dart:typed_data';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/form_input.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddUser extends StatefulWidget {
  const AddUser({
    super.key,
    required this.action,
  });

  final Function(String) action;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final UserController _userController = UserController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'user';
  Uint8List? image;
  bool isLoading = false;

  final List<String> roles = ['user', 'admin'];

  Future<void> addUser() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _userController.registerUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        profileImage: null,
      );

      if (!mounted) return;

      if (response?.errorMessage != null) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          "Neizdevās pievienot lietotāju: ${response?.errorMessage}",
        );
      } else {
        StylizedDialog.alert(context, "Veiksmīgi", "Lietotājs ir pievienots");
        widget.action("mng_users");
      }
    } catch (exception) {
      debugPrint(exception.toString());
      if (!mounted) return;

      StylizedDialog.alert(
        context,
        "Kļūda",
        "Neizdevās pievienot lietotāju",
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => image = bytes);
      } else {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() => image = bytes);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 1300,
        maxHeight: 800,
      ),
      decoration: classicDecorationDark,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: isLoading
          ? loading()
          : Center(
              child: Row(
                spacing: 15,
                children: [
                  userImageColumn(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 35,
                      ),
                      decoration: classicDecorationSharp,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            spacing: 15,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header(),
                              Divider(height: 20),
                              FormInput(
                                icon: Icons.person,
                                title: 'Vārds',
                                controller: nameController,
                                heightLines: 1,
                              ),
                              SizedBox(),
                              FormInput(
                                icon: Icons.email,
                                title: 'E-pasts',
                                controller: emailController,
                                heightLines: 1,
                              ),
                              SizedBox(),
                              FormInput(
                                icon: Icons.lock,
                                title: 'Parole',
                                controller: passwordController,
                                heightLines: 1,
                                isPassword: true,
                              ),
                              SizedBox(),
                              roleSelector(),
                            ],
                          ),
                          buttonRow(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget roleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 25,
              color: smokeyWhite,
            ),
            Text('Loma', style: bodyLarge),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Color.fromARGB(255, 123, 123, 123),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedRole,
              dropdownColor: Color.fromARGB(255, 44, 39, 39),
              style: bodyMedium,
              icon: Icon(Icons.arrow_drop_down, color: smokeyWhite),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue!;
                });
              },
              items: roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: classicDecorationWhiteSharper,
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 5,
          ),
          child: Text(
            "Pievienot jaunu lietotāju",
            style: header2Red,
          ),
        ),
        StylizedButton(
          action: () => widget.action("mng_users"),
          title: "Atpakaļ",
          icon: Icons.chevron_left_rounded,
          textStyle: header2Red,
          iconSize: 35,
        ),
      ],
    );
  }

  IntrinsicHeight buttonRow() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StylizedButton(
            action: addUser,
            title: "Pievienot lietotāju",
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  userImageColumn() {
    return IntrinsicHeight(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 390,
        ),
        decoration: classicDecorationSharp,
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                boxShadow: cardShadow,
              ),
              child: image != null
                  ? Image.memory(image!)
                  : Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
            ),
            SizedBox(height: 20),
            StylizedButton(
              action: _pickImage,
              title: "Pievienot bildi",
              icon: Icons.image,
            ),
          ],
        ),
      ),
    );
  }

  Center loading() {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: smokeyWhite,
        size: 100,
      ),
    );
  }
}
