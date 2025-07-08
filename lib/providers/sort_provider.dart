import 'package:flutter/material.dart';
import '../models/train_request_model.dart';

enum SortMode { none, ascending, descending }

class SortProvider extends ChangeNotifier {
  SortMode _sortMode = SortMode.none;

  SortMode get sortMode => _sortMode;

  void toggleSortMode() {
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
    notifyListeners();
  }

  void clearSort() {
    _sortMode = SortMode.none;
    notifyListeners();
  }

  /// ✅ Compare two TrainRequests based on journeyDate only
  int compare(TrainRequest a, TrainRequest b) {
    if (_sortMode == SortMode.none) return 0;

    int result = a.trainJourneyDate.compareTo(b.trainJourneyDate);
    return _sortMode == SortMode.ascending ? result : -result;
  }
}
