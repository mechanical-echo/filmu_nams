import 'package:filmu_nams/views/auth/auth_form.dart';
import 'package:filmu_nams/views/auth/registration_steps/email_not_verified.dart';
import 'package:filmu_nams/views/auth/registration_steps/registration_state.dart';
import 'package:filmu_nams/views/main/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationState = Provider.of<RegistrationState>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (user != null && !user.emailVerified) {
              return EmailNotVerified();
            }

            if (registrationState.isRegistrationComplete) {
              return Wrapper();
            }

            return AuthForm();
          }
          return AuthForm();
        },
      ),
    );
  }
}
