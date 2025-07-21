// lib/providers/zone_division_provider.dart
import 'package:flutter/material.dart';

class ZoneDivisionProvider with ChangeNotifier {
  List _zones = [];
  List _divisions = [];
  List _priorities = [];

  List get zones => _zones;
  List get divisions => _divisions;
  List get priorities => _priorities;

  void setData(List zones, List divisions, List priorities) {
    _zones = zones;
    _divisions = divisions;
    _priorities = priorities;
    notifyListeners();
  }
}
