import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'firebase_options.dart';
import 'package:filmu_nams/views/client/client.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/registration_state.dart';
import 'assets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('lv');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegistrationState()),
      ],
      child: App(theme: theme),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Platform.isWindows || Platform.isMacOS ? AdminAuth() : ClientApp(),
    );
  }
}
