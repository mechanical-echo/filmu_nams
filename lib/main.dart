import 'package:filmu_nams/controllers/notification_controller.dart';
import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:filmu_nams/views/admin/dashboard/admin_wrapper.dart';
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

// Import route definitions
import 'package:filmu_nams/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('lv');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationController().initialize();
    await PaymentController().initStripe();
  }

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
    return ContextTheme(
      themeProvider: themeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeProvider.currentTheme,
        initialRoute:
            Platform.isWindows || Platform.isMacOS ? '/admin/auth' : '/client',
        routes: {
          '/client': (context) => const ClientApp(),
          '/admin/auth': (context) => const AdminAuth(),
          '/admin/dashboard': (context) => const AdminWrapper(),
        },
        onGenerateRoute: (settings) =>
            generateAdminRoute(settings, themeProvider.currentTheme),
      ),
    );
  }
}
