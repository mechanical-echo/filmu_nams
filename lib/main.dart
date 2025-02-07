import 'package:filmu_nams/admin/admin_wrapper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:filmu_nams/views/auth/auth.dart';
import 'package:filmu_nams/views/auth/registration_steps/registration_state.dart';
import 'package:filmu_nams/views/main/profile/profile_details.dart';
import 'package:filmu_nams/views/main/wrapper.dart';
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
      home: kIsWeb ? AdminWrapper() : Auth(),
      routes: {
        '/home': (context) => Wrapper(),
        '/profile/details': (context) => ProfileDetails(),
      },
    );
  }
}
