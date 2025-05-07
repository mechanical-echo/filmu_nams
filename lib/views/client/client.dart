import 'package:filmu_nams/views/client/auth/auth_form.dart';
import 'package:filmu_nams/views/client/main/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({super.key});

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  String appGroupId = 'group.filmuNams';
  String iOSWidgetName = 'FilmuNamsWidget';
  String androidWidgetName = 'FilmuNamsWidget';

  String dataKey = 'text_from_flutter_app';

  void test() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      await HomeWidget.saveWidgetData(dataKey, "test");

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    test();
  }

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
