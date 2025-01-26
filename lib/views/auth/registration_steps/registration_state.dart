import 'package:flutter/foundation.dart';

class RegistrationState extends ChangeNotifier {
  bool _isRegistrationComplete = true;

  bool get isRegistrationComplete => _isRegistrationComplete;

  void setRegistrationComplete(bool value) {
    _isRegistrationComplete = value;
    notifyListeners();
  }
}
