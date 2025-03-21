import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/form_input.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditUser extends StatefulWidget {
  const EditUser({
    super.key,
    required this.id,
    required this.action,
  });

  final String id;
  final Function(int) action;

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final UserController _userController = UserController();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String selectedRole = 'user';

  UserModel? userData;
  Uint8List? image;
  bool isLoading = true;
  bool isCurrentUser = false;

  final List<String> roles = ['user', 'admin'];

  Future<void> fetchUserData() async {
    try {
      userData = await _userController.getUserById(widget.id);
      setState(() {
        nameController.text = userData!.name;
        emailController.text = userData!.email;
        selectedRole = userData!.role;
        isCurrentUser = FirebaseAuth.instance.currentUser?.uid == widget.id;
      });
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.alert(
            context, "Kļūda", 'Neizdevās dabūt lietotāja datus');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _userController.updateUser(
        widget.id,
        nameController.text,
        emailController.text,
        selectedRole,
        null,
        image,
      );

      if (mounted) {
        StylizedDialog.alert(context, "Veiksmīgi", "Lietotājs ir atjaunināts");
      }
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.alert(
            context, "Kļūda", "Neizdēvās atjaunināt lietotāju");
      }
    }
    setState(() {
      isLoading = false;
    });

    fetchUserData();
  }

  Future<void> deleteUser() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst lietotāju?", style: header2),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo lietotāju? Šo darbību nevar atsaukt.",
                  style: bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Atcelt"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[700]),
                    child: Text("Dzēst"),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        setState(() {
          isLoading = true;
        });

        await _userController.deleteUser(widget.id);

        if (mounted) {
          widget.action(3);
        }
      }
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.alert(context, "Kļūda", "Neizdēvās dzēst lietotāju");
      }
      setState(() {
        isLoading = false;
      });
    }
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
  void initState() {
    super.initState();
    fetchUserData();
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
      child: isLoading || userData == null
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
                              if (!isCurrentUser) roleSelector(),
                              SizedBox(),
                              userInfo(),
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

  Widget userInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: darkDecorationSharper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lietotāja informācija:', style: bodyMedium),
          SizedBox(height: 10),
          infoRow('Reģistrēts:', formatDate(userData!.createdAt.toDate())),
          infoRow('ID:', userData!.id),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: bodySmall),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: smokeyWhite.withAlpha(200),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: classicDecorationWhiteSharper,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 5,
              ),
              child: Text(
                userData!.name,
                style: header2Red,
              ),
            ),
            if (isCurrentUser)
              Positioned(
                top: -50,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: -12,
                      child: Icon(
                        Icons.add_location_rounded,
                        color: smokeyWhite,
                        size: 50,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: classicDecorationWhiteSharper,
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.person,
                            color: red001,
                          ),
                          Text(
                            'Jūsu profils',
                            style: bodyMediumRed,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
        StylizedButton(
          action: () => widget.action(3),
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
            action: updateUser,
            title: "Saglabāt izmaiņas",
            icon: Icons.save,
          ),
          if (!isCurrentUser)
            StylizedButton(
              action: deleteUser,
              title: "Dzēst lietotāju",
              icon: Icons.delete_forever,
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
                  : CachedNetworkImage(
                      imageUrl: userData!.profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => loading(),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey[800],
                          child:
                              Icon(Icons.error, color: Colors.white, size: 50),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            StylizedButton(
              action: _pickImage,
              title: "Mainīt bildi",
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
