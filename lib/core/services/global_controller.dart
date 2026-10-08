import 'package:flutter/material.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

class GlobalController extends ChangeNotifier {
  String? _token;
  UserUiModel? _currentUser;

  // Getters
  String? get token => _token;
  UserUiModel? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Setters
  void setToken(String? value) {
    if (_token == value) return;
    _token = value;
    notifyListeners();
  }

  void setCurrentUser(UserUiModel? user) {
    _currentUser = user;
    if (user != null) {
      _token = user.token;
    }
    notifyListeners();
  }

  void reset() {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}