import 'package:filmu_nams/views/client/auth/auth_form.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/email_not_verified.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/registration_state.dart';
import 'package:filmu_nams/views/client/main/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

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
