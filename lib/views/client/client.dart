import 'package:filmu_nams/views/client/auth/auth_form.dart';
import 'package:filmu_nams/views/client/main/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Wrapper();
          }

          return AuthForm();
        },
      ),
    );
  }
}
