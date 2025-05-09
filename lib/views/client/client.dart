import 'package:filmu_nams/controllers/widget_controller.dart';
import 'package:filmu_nams/views/client/auth/auth_form.dart';
import 'package:filmu_nams/views/client/main/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({super.key});

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  @override
  void initState() {
    super.initState();
    _initializeWidget();
  }

  Future<void> _initializeWidget() async {
    await TicketWidgetController.initialize();

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await TicketWidgetController.updateTicketsWidget();

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          TicketWidgetController.updateTicketsWidget();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Wrapper();
          }
          return const AuthForm();
        },
      ),
    );
  }
}
