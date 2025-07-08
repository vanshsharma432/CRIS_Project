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
  bool showDropdown = false;
  bool showPriorityEditor = false;
  bool isSaved = false;

  late TextEditingController _priorityController;

  @override
  void initState() {
    super.initState();
    _priorityController = TextEditingController(text: widget.initialPriority.toString());
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
        // Edit / Saved button
        TextButton.icon(
          onPressed: () {
            setState(() {
              showDropdown = !showDropdown;
              isSaved = false;
              showPriorityEditor = false;
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

        // Dropdown options
        if (showDropdown && !showPriorityEditor)
          Container(
            decoration: BoxDecoration(
              color: AColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownOption(
                  icon: Icons.low_priority,
                  text: "Change Priority",
                  onTap: () {
                    setState(() {
                      showPriorityEditor = true;
                      showDropdown = false;
                    });
                  },
                ),
                _buildDropdownOption(
                  icon: Icons.block,
                  text: "Reject",
                  onTap: () {
                    widget.onRejected();
                    setState(() {
                      showDropdown = false;
                      isSaved = true;
                    });
                  },
                ),
              ],
            ),
          ),

        // Priority Input UI
        if (showPriorityEditor)
          Row(
            children: [
              SizedBox(
                width: isDesktop ? 60 : 50,
                child: TextField(
                  controller: _priorityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    hintText: "0-3",
                    hintStyle: ATextStyles.bodySmall.copyWith(color: AColors.gray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  style: ATextStyles.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final newPriority = int.tryParse(_priorityController.text.trim());
                  if (newPriority != null) {
                    widget.onPriorityChanged(newPriority);
                    setState(() {
                      isSaved = true;
                      showPriorityEditor = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text("Save", style: ATextStyles.buttonSmall.copyWith(color: AColors.white)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDropdownOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AColors.secondary, size: 18),
            const SizedBox(width: 8),
            Text(text, style: ATextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
