import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';

class FilterProvider extends ChangeNotifier {
  String? _selectedField;
  dynamic _filterValue;

  String? get selectedField => _selectedField;
  dynamic get filterValue => _filterValue;

  final List<String> filterFields = [
    AStrings.total,
    AStrings.requested,
    AStrings.accepted,
    AStrings.currentStatus,
    AStrings.remarksByRailways,
    AStrings.trainStartDate,
    AStrings.requestedOn,
  ];

  List<Map<String, dynamic>> _zoneList = [];
  List<Map<String, dynamic>> _divisionList = [];
  List<Map<String, dynamic>> _priorityList = [];

  List<Map<String, dynamic>> get zoneList => _zoneList;
  List<Map<String, dynamic>> get divisionList => _divisionList;
  List<Map<String, dynamic>> get priorityList => _priorityList;

  void setZoneList(List<Map<String, dynamic>> zones) {
    _zoneList = zones;
    notifyListeners();
  }

  void setDivisionList(List<Map<String, dynamic>> divisions) {
    _divisionList = divisions;
    notifyListeners();
  }

  void setPriorityList(List<Map<String, dynamic>> priorities) {
    _priorityList = priorities;
    notifyListeners();
  }

  void setSelectedField(String? field) {
    _selectedField = field;
    _filterValue = null;
    notifyListeners();
  }

  void setFilterValue(dynamic value) {
    _filterValue = value;
    notifyListeners();
  }

  void clearFilter() {
    _selectedField = null;
    _filterValue = null;
    notifyListeners();
  }

  bool matches(dynamic item) {
    if (_selectedField == null || _filterValue == null || _filterValue.toString().isEmpty) return true;

    final filterText = _filterValue.toString().toLowerCase();

    try {
      switch (_selectedField) {
        case AStrings.total:
          return item.totalPassengers.toString().contains(filterText);
        case AStrings.requested:
          return item.requestedPassengers.toString().contains(filterText);
        case AStrings.accepted:
          return item.acceptedPassengers.toString().contains(filterText);
        case AStrings.currentStatus:
          return item.currentStatus.toLowerCase().contains(filterText);
        case AStrings.remarksByRailways:
          return item.remarksByRailways.toLowerCase().contains(filterText);
        case AStrings.trainStartDate:
          return item.trainStartDate.toString().contains(filterText);
        case AStrings.requestedOn:
          return item.requestedOn.toString().contains(filterText);
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }

  // 👇 New methods to support filter_widget.dart logic

  void updateSelectedField(String? field) => setSelectedField(field);

  void updateTextFilter(String value) => setFilterValue(value);

  void updateMin(String value) {
    final min = int.tryParse(value);
    if (min != null) setFilterValue({'min': min});
  }

  void updateMax(String value) {
    final max = int.tryParse(value);
    if (max != null && _filterValue is Map) {
      final current = Map<String, int>.from(_filterValue);
      current['max'] = max;
      setFilterValue(current);
    }
  }

  void updateSelectedDate(DateTime date) => setFilterValue(date);
}
