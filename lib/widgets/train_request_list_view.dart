import 'package:flutter/material.dart';
import '../models/train_request_model.dart';
import 'train_request_card.dart';

  final List<TrainRequest> allRequests;
  final ValueChanged<TrainRequest> onUpdate;

  const TrainRequestListView({
    super.key,
    required this.allRequests,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
      padding: const EdgeInsets.symmetric(vertical: 8),
            request: request,
            onSelectionChanged: (bool? newValue) {
              final updated = request.copyWith(isSelected: newValue ?? false);
            },
            onPriorityChanged: (int newPriority) {
              final updated = request.copyWith(priority: newPriority);
            },
            onRejected: () {
              final updated = request.copyWith(currentStatus: 'Rejected');
            },
    );
  }
}
