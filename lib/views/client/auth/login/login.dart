import 'package:filmu_nams/views/client/auth/login/login_controller.dart';
import 'package:filmu_nams/views/client/auth/login/login_validator.dart';
import 'package:filmu_nams/views/client/auth/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  final void Function(int? view) onViewChange;

  const Login({
    super.key,
    required this.onViewChange,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _loginController.login(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoginView(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      isLoading: _isLoading,
      obscurePassword: _obscurePassword,
      onPasswordVisibilityToggle: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      onLogin: _handleLogin,
      onViewChange: widget.onViewChange,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pieslēgties',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ievadiet savu e-pastu un paroli',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: LoginValidator.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'E-pasts',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  validator: LoginValidator.validatePassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Parole',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: theme.colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Pieslēgties',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => widget.onViewChange(1),
                  child: Text(
                    'Vai vēlaties reģistrēties?',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
