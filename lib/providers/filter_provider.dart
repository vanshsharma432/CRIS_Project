import 'package:flutter/material.dart';
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
    AStrings.seatClass,
    AStrings.requestedByName,
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
    if (_selectedField == null ||
        _filterValue == null ||
        _filterValue.toString().isEmpty) {
      return true;
    }

    // NOTE: This corrected version handles Text, Date, and Range filters
    // as discussed in the previous reviews.

    try {
      // --- Date Filtering ---
      if (_filterValue is DateTime) {
        DateTime filterDate = _filterValue as DateTime;
        DateTime? itemDate;
        if (_selectedField == AStrings.trainStartDate)
          itemDate = item.trainStartDate;
        if (_selectedField == AStrings.requestedOn) itemDate = item.requestedOn;
        if (itemDate == null) return false;
        return itemDate.year == filterDate.year &&
            itemDate.month == filterDate.month &&
            itemDate.day == filterDate.day;
      }

      // --- Numeric Range Filtering ---
      if (_filterValue is Map) {
        final valueMap = _filterValue as Map<String, dynamic>;
        final min = valueMap['min'] as int?;
        final max = valueMap['max'] as int?;
        int? itemValue;
        if (_selectedField == AStrings.total) itemValue = item.totalPassengers;
        if (_selectedField == AStrings.requested)
          itemValue = item.requestedPassengers;
        if (_selectedField == AStrings.accepted)
          itemValue = item.acceptedPassengers;
        if (itemValue == null) return false;
        final minOK = min == null || itemValue >= min;
        final maxOK = max == null || itemValue <= max;
        return minOK && maxOK;
      }

      // --- Text Filtering (Corrected) ---
      final filterText = _filterValue.toString().toLowerCase();

      switch (_selectedField) {
        case AStrings.currentStatus:
          return item.currentStatus.toLowerCase().contains(filterText);
        case AStrings.remarksByRailways:
          return item.remarksByRailways.toLowerCase().contains(filterText);
        case AStrings.requestedByName:
          return item.requestedBy.toLowerCase().contains(filterText);

        // ✅ FIXED: Corrected case-sensitivity for "Class"
        case AStrings.seatClass:
          return item.journeyClass.toString().toLowerCase().contains(
            filterText,
          );

        // ✅ ADDED: Missing case for "Division"
        case AStrings.division:
          return item.division.toString().toLowerCase().contains(filterText);

        // ✅ ADDED: Missing case for "Zone"
        case AStrings.zone:
          return item.zone.toString().toLowerCase().contains(filterText);

        // If no text field matches, assume it's not a text filter
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }

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
