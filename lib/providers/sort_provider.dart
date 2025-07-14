import 'package:flutter/material.dart';
import '../models/train_request_model.dart';

enum SortMode { none, ascending, descending }

class SortProvider extends ChangeNotifier {
  SortMode _sortMode = SortMode.none;
  String? _currentSortField;

  SortMode get sortMode => _sortMode;
  String? get currentSortField => _currentSortField;

  void toggleSortField(String field) {
    if (_currentSortField == field) {
      // If already sorting this field, toggle the sort mode
      switch (_sortMode) {
        case SortMode.none:
          _sortMode = SortMode.ascending;
          break;
        case SortMode.ascending:
          _sortMode = SortMode.descending;
          break;
        case SortMode.descending:
          _sortMode = SortMode.none;
          break;
      }
    } else {
      // New sort field — reset mode to ascending
      _currentSortField = field;
      _sortMode = SortMode.ascending;
    }
    notifyListeners();
  }

  void clearSort() {
    _sortMode = SortMode.none;
    _currentSortField = null;
    notifyListeners();
  }

  /// 🧠 Custom comparator based on selected field
  int compare(TrainRequest a, TrainRequest b) {
    if (_sortMode == SortMode.none || _currentSortField == null) return 0;

    int result = 0;

    switch (_currentSortField) {
      case 'pnr':
        result = a.pnr.compareTo(b.pnr);
        break;
      case 'trainStartDate':
        result = a.trainStartDate.compareTo(b.trainStartDate);
        break;
      case 'trainNo':
        result = a.trainNo.compareTo(b.trainNo);
        break;
      case 'division':
        result = a.division.compareTo(b.division);
        break;
      case 'seatClass':
        result = a.seatClass.compareTo(b.seatClass);
        break;
      case 'totalPassengers':
        result = a.totalPassengers.compareTo(b.totalPassengers);
        break;
      case 'requestedBy':
        result = a.requestedBy.compareTo(b.requestedBy);
        break;
      case 'currentStatus':
        result = a.currentStatus.compareTo(b.currentStatus);
        break;
      default:
        result = 0;
    }

    return _sortMode == SortMode.ascending ? result : -result;
  }
}
