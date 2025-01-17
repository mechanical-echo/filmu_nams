import 'package:filmu_nams/views/auth/login.dart';
import 'package:filmu_nams/views/main/start.dart';
import 'package:flutter/material.dart';
import 'assets/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('lv');

  runApp(App(
    theme: theme,
  ));
}

class App extends StatelessWidget {
  const App({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Login(),
      routes: {'/login': (context) => Login(), '/home': (context) => Start()},
    );
  }
}
