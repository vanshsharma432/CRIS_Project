import 'package:flutter/material.dart';
import '../models/train_request_model.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EditOptionsWidget extends StatefulWidget {
  final int initialPriority;
  final ValueChanged<int> onPriorityChanged;
  final VoidCallback onRejected;

  const EditOptionsWidget({
    super.key,
    required this.initialPriority,
    required this.onPriorityChanged,
    required this.onRejected,
  });

  @override
  State<EditOptionsWidget> createState() => _EditOptionsWidgetState();
}

class _EditOptionsWidgetState extends State<EditOptionsWidget> {
  bool showActions = false;
  bool isSaved = false;

  late TextEditingController _priorityController;

  @override
  void initState() {
    super.initState();
    _priorityController = TextEditingController(
      text: widget.initialPriority.toString(),
    );
  }

  @override
  void dispose() {
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              showActions = !showActions;
              isSaved = false;
            });
          },
          icon: Icon(
            isSaved ? Icons.check_circle_outline : Icons.edit,
            size: 18,
            color: isSaved ? AColors.primary : AColors.brandeisBlue,
          ),
          label: Text(
            isSaved ? "Saved" : "Edit",
            style: ATextStyles.buttonSmall.copyWith(
              color: isSaved ? AColors.primary : AColors.brandeisBlue,
            ),
          ),
        ),

        if (showActions)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reject Button (red ❌)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onRejected();
                      setState(() {
                        showActions = false;
                        isSaved = true;
                      });
                    },
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    tooltip: 'Reject',
                  ),
                ),
                const SizedBox(width: 6),

                // Priority Input
                SizedBox(
                  width: isDesktop ? 60 : 50,
                  child: TextField(
                    controller: _priorityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      hintText: "0–3",
                      hintStyle: ATextStyles.bodySmall.copyWith(color: AColors.gray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    style: ATextStyles.bodySmall,
                  ),
                ),
                const SizedBox(width: 6),

                // Save Button (blue ✔️)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final newPriority = int.tryParse(_priorityController.text.trim());
                      if (newPriority != null) {
                        widget.onPriorityChanged(newPriority);
                        setState(() {
                          isSaved = true;
                          showActions = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.check, size: 16),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: AColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    tooltip: 'Save Priority',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
