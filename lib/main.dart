import 'package:filmu_nams/controllers/notification_controller.dart';
import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'controllers/payment_controller.dart';
import 'firebase_options.dart';
import 'package:filmu_nams/views/client/client.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/registration_state.dart';
import 'package:filmu_nams/providers/theme_provider.dart';
import 'package:filmu_nams/providers/color_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('lv');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationController().initialize();
  }

  await PaymentController().initStripe();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => RegistrationState()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: const ThemedApp(),
      ),
    );
  });
}

class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ColorContext(
      themeProvider: themeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeProvider.currentTheme,
        home:
            Platform.isWindows || Platform.isMacOS ? AdminAuth() : ClientApp(),
      ),
    );
  }
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
