import 'package:filmu_nams/views/client/auth/login/social_login_button.dart';
import 'package:filmu_nams/controllers/login_controller.dart';
import 'package:filmu_nams/views/client/auth/login/login_validator.dart';
import 'package:filmu_nams/views/client/auth/login/login_view.dart';
import 'package:flutter/material.dart';

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
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pieslēgties',
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ievadiet savu e-pastu un paroli',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.home_outlined,
                    color: theme.textTheme.displaySmall!.color,
                    size: 42,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: LoginValidator.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-pasts',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  validator: LoginValidator.validatePassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Parole',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Ielogoties',
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        iconPath: 'assets/google.png',
                        label: 'Google',
                        onPressed: _loginController.signInWithGoogle,
                      ),
                    ),
                    Expanded(
                      child: SocialLoginButton(
                        iconPath: 'assets/facebook.png',
                        label: 'Facebook',
                        onPressed: _loginController.signInWithFacebook,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => widget.onViewChange(1),
                  child: Text('Vai vēlaties reģistrēties?'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
