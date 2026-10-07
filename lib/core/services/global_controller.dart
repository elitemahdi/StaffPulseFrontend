

import 'package:flutter/material.dart';

class GlobalController extends ChangeNotifier {
  //variables
  String? _token;


  // getters
  String? get token => _token;


  // Setters with notifyListeners to update UI
  void setToken(String? value) {
    if (_token == value) return;
    _token = value;
    notifyListeners();
  }

  
  void reset() {
    _token = null;
    notifyListeners();
  }

}