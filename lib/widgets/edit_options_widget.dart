import 'package:dashboard_final/constants/strings.dart';
import 'package:flutter/material.dart';
import '../services/API.dart'; // Import your API service
import '../theme/colors.dart';

class EditOptionsWidget extends StatefulWidget {
  final int initialPriority;
  final String eqRequestNo; // Add this parameter
  final ValueChanged<int> onPriorityChanged;
  final VoidCallback onRejected;
  const EditOptionsWidget({
    super.key,
    required this.initialPriority,
    required this.eqRequestNo, // New required parameter
    required this.onPriorityChanged,
    required this.onRejected,
  });

  @override
  State<EditOptionsWidget> createState() => _EditOptionsWidgetState();
}

class _EditOptionsWidgetState extends State<EditOptionsWidget> {
  bool isSaved = false;
  bool isLoading = false;
  Future<void> _handlePriorityChange(int priority) async {
    setState(() => isLoading = true);

    try {
      final success = await MRApiService.updatePriority(
        eqRequestNo: widget.eqRequestNo,
        priority: priority,
        remarks: "Priority changed to $priority", // Customize remarks as needed
      );

      if (success) {
        widget.onPriorityChanged(priority);
        setState(() => isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Priority updated successfully')),
        );
      } else {
        throw Exception('Failed to update priority');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleSelected(dynamic value) {
    if (value == 'reject') {
      widget.onRejected();
      setState(() => isSaved = true);
    } else if (value is int) {
      _handlePriorityChange(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PopupMenuButton<dynamic>(
          icon: Icon(
            isSaved ? Icons.check_circle_outline : Icons.edit,
            color: isSaved ? AColors.primary : AColors.brandeisBlue,
            size: 20,
          ),
          tooltip: 'Edit',
          onSelected: _handleSelected,
          itemBuilder: (context) => [
            ...List.generate(
              5,
              (index) => PopupMenuItem(
                value: index + 1,
                child: Text("${AppConstants.priorityOptions[index]['label']}"),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'reject',
              child: Row(
                children: [
                  Icon(Icons.close, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text("Reject", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        if (isLoading)
          const Positioned(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}