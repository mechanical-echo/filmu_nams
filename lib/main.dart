import 'package:filmu_nams/views/auth/login.dart';
import 'package:filmu_nams/views/main/start.dart';
import 'package:flutter/material.dart';
import 'package:json_theme_plus/json_theme_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

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
      home: Start(),
      routes: {'/login': (context) => Login(), '/home': (context) => Start()},
    );
  }
}
