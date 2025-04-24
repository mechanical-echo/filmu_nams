import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({
    super.key,
    this.id,
  });

  final String? id;

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  Style get theme => Style.of(context);

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserModel? userData;
  bool isLoading = true;
  bool isUpdating = false;
  bool isCurrentUser = false;
  bool showPassword = false;
  String selectedRole = 'user';
  Uint8List? imageData;
  bool deleteImage = false;

  List<String> roles = ['user', 'admin'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      isCurrentUser = widget.id == currentUser?.uid;

      UserModel? user;
      if (widget.id != null) {
        user = await _userController.getUserById(widget.id!);
        if (user != null) {
          setState(() {
            nameController.text = user!.name;
            emailController.text = user.email;
            selectedRole = user.role;
          });
        }
      }

      setState(() {
        userData = user;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās ielādēt datus",
        );
      }
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final String name = nameController.text;
      final String email = emailController.text;

      bool success;

      if (widget.id == null) {
        final String password = passwordController.text;

        final String? newId = await _userController.createUser(
          email: email,
          password: password,
          name: name,
          role: selectedRole,
          profileImage: imageData,
        );

        success = newId != null;
        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Lietotājs pievienots",
          );
        }
      } else {
        success = await _userController.updateUser(
          uid: widget.id!,
          name: name,
          email: email,
          role: selectedRole,
          profileImage: imageData,
          deleteImage: deleteImage,
        );

        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Lietotājs atjaunināts",
          );
        }
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (!success && mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt lietotāju",
        );
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt lietotāju: ${e.toString()}",
        );
      }
    }

    setState(() {
      isUpdating = false;
    });
  }

  Future<void> _deleteUser() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst lietotāju?", style: theme.headlineMedium),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo lietotāju? Šo darbību nevar atsaukt.",
                  style: theme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Atcelt"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    child: const Text("Dzēst"),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        setState(() {
          isUpdating = true;
        });

        final bool success = await _userController.deleteUser(widget.id!);

        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            StylizedDialog.dialog(
              Icons.check_circle_outline,
              context,
              "Veiksmīgi",
              "Lietotājs dzēsts",
            );
          } else {
            setState(() {
              isUpdating = false;
            });
            StylizedDialog.dialog(
              Icons.error_outline,
              context,
              "Kļūda",
              "Neizdevās dzēst lietotāju",
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās dzēst lietotāju",
        );
      }
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageData = bytes;
          deleteImage = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās izvēlēties attēlu: ${e.toString()}",
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      imageData = null;
      deleteImage = true;
    });
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: isLoading || isUpdating
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.contrast,
                    size: 80,
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(),
                              const SizedBox(width: 32),
                              Expanded(child: _buildFormContent()),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildButtonRow(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.id == null ? "Jauns lietotājs" : "Rediģēt lietotāju",
          style: theme.displayMedium,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: theme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: theme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageData != null
              ? Image.memory(imageData!, fit: BoxFit.cover)
              : deleteImage || (userData?.profileImageUrl.isEmpty ?? true)
                  ? Icon(Icons.person, size: 100, color: theme.primary)
                  : CachedNetworkImage(
                      imageUrl: userData!.profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: theme.primary,
                          size: 50,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 100,
                        color: theme.primary,
                      ),
                    ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload),
              label: Text('Mainīt attēlu'),
            ),
            if (!(userData?.profileImageUrl.isEmpty ?? true) &&
                !deleteImage) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _removeImage,
                icon: Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Dzēst attēlu',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Vārds',
            hintText: 'Ievadiet lietotāja vārdu',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet vārdu';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'E-pasts',
            hintText: 'Ievadiet e-pasta adresi',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet e-pastu';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Lūdzu ievadiet derīgu e-pasta adresi';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
        ),
        if (widget.id == null) ...[
          const SizedBox(height: 24),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Parole',
              hintText: 'Ievadiet paroli (vismaz 6 simboli)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
            ),
            obscureText: !showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lūdzu ievadiet paroli';
              }
              if (value.length < 6) {
                return 'Parolei jābūt vismaz 6 simboliem';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Loma:',
          style: theme.titleLarge,
        ),
        const SizedBox(height: 8),
        ToggleButtons(
          onPressed: isCurrentUser
              ? null
              : (int index) {
                  setState(() {
                    selectedRole = roles[index];
                  });
                },
          isSelected: [
            selectedRole == roles[0],
            selectedRole == roles[1],
          ],
          borderRadius: BorderRadius.circular(8),
          selectedColor: theme.onPrimary,
          fillColor: theme.primary,
          disabledColor: theme.contrast.withOpacity(0.3),
          constraints: const BoxConstraints(
            minWidth: 150.0,
            minHeight: 50.0,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Lietotājs'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Administrators'),
            ),
          ],
        ),
        if (isCurrentUser)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Nevar mainīt pašreizējā lietotāja lomu',
              style: theme.bodySmall.copyWith(color: Colors.orange),
            ),
          ),
        if (userData != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lietotāja informācija:',
                  style: theme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        Icons.badge,
                        'ID:',
                        userData!.id,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        Icons.calendar_today,
                        'Reģistrēts:',
                        _formatDate(userData!.createdAt),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.id != null && !isCurrentUser)
          TextButton(
            onPressed: _deleteUser,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: Text("Dzēst"),
          ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Atcelt"),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: _saveUser,
          child: Text(widget.id == null ? "Pievienot" : "Saglabāt"),
        ),
      ],
    );
  }
}
