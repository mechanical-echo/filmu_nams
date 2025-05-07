import 'package:filmu_nams/controllers/notification_controller.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:window_size/window_size.dart';
import 'controllers/payment_controller.dart';
import 'firebase_options.dart';
import 'package:filmu_nams/views/client/client.dart';
import 'package:filmu_nams/providers/theme_provider.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

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

  if (Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(770, 600));
    setWindowFrame(const Rect.fromLTRB(0, 0, 770, 600));
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: const ThemedApp(),
      ),
    );
  });

  // tikai prieks debug: palidz ar sertifikatu kludu kashotam bildem android emulator videe
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
}

class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Style(
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
