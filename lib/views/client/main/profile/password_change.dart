import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
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

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
            content: Text(
              'Parole veiksmīgi nomainīta',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -35,
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'Mainīt paroli',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
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
                children: [
                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.withOpacity(0.9),
                            size: 24,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(
                                color: Colors.red.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildPasswordField(
                    'Pašreizējā parole',
                    _currentPasswordController,
                    _obscureCurrentPassword,
                    (value) {
                      setState(() {
                        _obscureCurrentPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    'Jaunā parole',
                    _newPasswordController,
                    _obscureNewPassword,
                    (value) {
                      setState(() {
                        _obscureNewPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    'Apstiprināt jauno paroli',
                    _confirmPasswordController,
                    _obscureConfirmPassword,
                    (value) {
                      setState(() {
                        _obscureConfirmPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    Function(bool) onToggleVisibility,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: () => onToggleVisibility(!obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lūdzu ievadiet paroli';
        }
        if (label == 'Jaunā parole' && value.length < 6) {
          return 'Parolei jābūt vismaz 6 simbolus garai';
        }
        if (label == 'Apstiprināt jauno paroli' &&
            value != _newPasswordController.text) {
          return 'Paroles nesakrīt';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _changePassword,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _isLoading
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.9),
                  ),
                )
              else
                Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              const SizedBox(width: 8),
              Text(
                _isLoading ? 'Maina paroli...' : 'Mainīt paroli',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
