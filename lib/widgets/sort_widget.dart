import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sort_provider.dart';
import '../constants/strings.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SortWidget extends StatelessWidget {
  const SortWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);

    IconData getSortIcon() {
      switch (sortProvider.sortMode) {
        case SortMode.ascending:
          return Icons.arrow_upward;
        case SortMode.descending:
          return Icons.arrow_downward;
        default:
          return Icons.unfold_more;
      }
    }

    String getSortLabel() {
      switch (sortProvider.sortMode) {
        case SortMode.ascending:
          return AStrings.ascending;
        case SortMode.descending:
          return AStrings.descending;
        default:
          return AStrings.defaultSort;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                sortProvider.toggleSortField('trainJourneyDate'),
            icon: Icon(getSortIcon(), size: 20),
            label: const Text("Sort"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.brandeisBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: ATextStyles.button,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            getSortLabel(),
            style: ATextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
