import 'package:flutter/material.dart';
import '../models/train_request_model.dart';
import 'train_request_card.dart';

class TrainRequestListView extends StatelessWidget {
  final List<TrainRequest> allRequests;
  final ValueChanged<TrainRequest> onUpdate;
  final void Function({
  required int startIndex,
  required int endIndex,
  required int totalCount,
  }) onPaginationChanged;

  const TrainRequestListView({
    super.key,
    required this.allRequests,
    required this.onUpdate,
    required this.onPaginationChanged,
  });

  @override
  Widget build(BuildContext context) {
    // No need to notify again — already paginated outside
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: allRequests.length,
      itemBuilder: (context, index) {
        final request = allRequests[index];
        return TrainRequestCard(
          request: request,
          onSelectionChanged: (bool? newValue) {
            final updated = request.copyWith(isSelected: newValue ?? false);
            onUpdate(updated);
          },
          onPriorityChanged: (int newPriority) {
            final updated = request.copyWith(priority: newPriority);
            onUpdate(updated);
          },
          onRejected: () {
            final updated = request.copyWith(currentStatus: 'Rejected');
            onUpdate(updated);
          },
        );
      },
    );
  }
}
