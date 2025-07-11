import 'package:flutter/material.dart';
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
  bool isSaved = false;


    );
  }

  @override
  Widget build(BuildContext context) {
      children: [
          icon: Icon(
            isSaved ? Icons.check_circle_outline : Icons.edit,
            color: isSaved ? AColors.primary : AColors.brandeisBlue,
            ),
          ),
        ),
                children: [
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}