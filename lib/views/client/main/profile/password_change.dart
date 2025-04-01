import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          _errorMessage = 'Lietotājs nav autorizējies';
          _isLoading = false;
        });
        return;
      }

      // Reauthenticate user with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(_newPasswordController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parole veiksmīgi nomainīta'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = AuthErrorCodes.getMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Neparedzēta kļūda: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);

    InputDecoration textFieldDec = InputDecoration(
      hintText: 'Ievadiet paroli',
      prefixIcon: Icon(Icons.password),
      filled: true,
      fillColor: colors.isLightTheme ? colors.smokeyWhite : colors.color002,
      hintStyle: colors.bodySmallThemeColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colors.color003),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.red),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: colors.color001,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Container(
          decoration: colors.classicDecorationDark,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -35,
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
              Text(
                'Mainīt paroli',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Background(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  header('Paroles maiņa', colors),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Esošā parole",
                      style: colors.bodyLarge,
                    ),
                  ),

                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: textFieldDec,
                    style: colors.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lūdzu, ievadiet pašreizējo paroli';
                      }
                      return null;
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Jaunā parole",
                      style: colors.bodyLarge,
                    ),
                  ),

                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: textFieldDec,
                    style: colors.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lūdzu, ievadiet jauno paroli';
                      }
                      
                      if (value.length < 8) {
                        return 'Parolei jābūt vismaz 8 simboliem garai';
                      }
                      
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Parolē jābūt vismaz 1 lielām burtam';
                      }
                      
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Parolē jābūt vismaz 1 mazām burtam';
                      }
                      
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Parolē jābūt vismaz 1 skaitlim';
                      }
                      
                      return null;
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Jaunā parole atkārtoti",
                      style: colors.bodyLarge,
                    ),
                  ),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: textFieldDec,
                    style: colors.bodyMedium,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Paroles nesakrīt';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : FilledTextIconButton(
                          icon: Icons.check,
                          title: "Saglabāt izmaiņas",
                          onPressed: _changePassword,
                          paddingY: 8,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget header(String title, ColorContext colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: colors.header2,
      ),
    );
  }
}