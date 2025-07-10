import 'package:flutter/material.dart';
import '../models/train_request_model.dart';
import 'train_request_card.dart';

class TrainRequestListView extends StatefulWidget {
  final List<TrainRequest> allRequests;
  final ValueChanged<TrainRequest> onUpdate;

  const TrainRequestListView({
    super.key,
    required this.allRequests,
    required this.onUpdate,
  });

  @override
  State<TrainRequestListView> createState() => _TrainRequestListViewState();
}

class _TrainRequestListViewState extends State<TrainRequestListView> {
  int currentPage = 0;
  int itemsPerPage = 20; // You can add a dropdown for user to change this.

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.allRequests.length / itemsPerPage).ceil();
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, widget.allRequests.length);
    final paginatedRequests = widget.allRequests.sublist(start, end);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...paginatedRequests.map(
          (request) => TrainRequestCard(
            request: request,
            onSelectionChanged: (bool? newValue) {
              final updated = request.copyWith(isSelected: newValue ?? false);
              widget.onUpdate(updated);
            },
            onPriorityChanged: (int newPriority) {
              final updated = request.copyWith(priority: newPriority);
              widget.onUpdate(updated);
            },
            onRejected: () {
              final updated = request.copyWith(currentStatus: 'Rejected');
              widget.onUpdate(updated);
            },
          ),
        ),

        // Pagination Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Show $itemsPerPage entries',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),

              TextButton(
                onPressed: currentPage > 0 ? () => setState(() => currentPage = 0) : null,
                child: const Text('First'),
              ),
              TextButton(
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                child: const Text('Previous'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${currentPage + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: currentPage < totalPages - 1
                    ? () => setState(() => currentPage++)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
