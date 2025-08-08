import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';
import 'package:provider/provider.dart';
import '../providers/sort_provider.dart';

/// 📅 Date Helpers
String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
String formatDateTime(DateTime date) =>
    DateFormat('dd MMM yyyy hh:mm a').format(date);

/// 🟢 Table cell for desktop
class TableCellText extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;

  const TableCellText(this.text, {this.color, this.bold = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: ATextStyles.tableCell.copyWith(
          color: color ?? AColors.darkText,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// 👥 Passenger metric column (Total, Requested, Accepted)
class PassengerMetric extends StatelessWidget {
  final String label;
  final String value;

  const PassengerMetric(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(label, style: ATextStyles.passengerLabel),
          Text(value, style: ATextStyles.passengerValue),
        ],
      ),
    );
  }
}

/// 📄 Row with icon, label and value (mobile view)
class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final double iconSize;

  const IconTextRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        if (label.isNotEmpty) Text(label, style: ATextStyles.bodyBold),
        Text(value, style: ATextStyles.bodySmall),
      ],
    );
  }
}

/// ✅ Selection checkbox (used in desktop & mobile)
class SelectionCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const SelectionCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        return AColors.lightGray;
      }),
      checkColor: AColors.brandeisBlue,
    );
  }
}

/// 🧾 Reusable table header cell
class TableHeaderCell extends StatelessWidget {
  final String text;
  final bool isSearching;
  final TextEditingController controller;
  final VoidCallback onTap;

  const TableHeaderCell(
    this.text, {
    required this.isSearching,
    required this.controller,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: ATextStyles.tableHeader.copyWith(
              color: isSearching ? AColors.primary : AColors.textPrimary,
              decoration: isSearching ? TextDecoration.underline : null,
            ),
          ),
          if (isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DesktopHeaderRow extends StatelessWidget {
  final int? activeSearchColumn;
  final List<TextEditingController> headerControllers;
  final void Function(int columnIndex) onColumnTapped;

  final int startIndex;
  final int endIndex;
  final int totalCount;

  const DesktopHeaderRow({
    super.key,
    required this.headerControllers,
    required this.onColumnTapped,
    this.activeSearchColumn,
    required this.startIndex,
    required this.endIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);

    final titles = [
      AStrings.pnrJourney,
      AStrings.startDate,
      AStrings.trainInfo,
      AStrings.seatClass,
      AStrings.divisionZone,
      AStrings.passengers,
      AStrings.requestedBy,
      AStrings.status,
    ];

    final fieldKeys = [
      'pnr',
      'trainStartDate',
      'trainNo',
      'seatClass',
      'division',
      'passengerCount', // Not sortable
      'requestedBy',
      'currentStatus',
    ];

    IconData getSortIcon(String field) {
      if (sortProvider.currentSortField != field) return Icons.unfold_more;
      switch (sortProvider.sortMode) {
        case SortMode.ascending:
          return Icons.arrow_upward;
        case SortMode.descending:
          return Icons.arrow_downward;
        default:
          return Icons.unfold_more;
      }
    }

    return Container(
      color: AColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        // --- COLUMN WIDTHS MODIFIED HERE ---
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FixedColumnWidth(120),
          2: FixedColumnWidth(150), // Reduced width
          3: FixedColumnWidth(120),
          4: FixedColumnWidth(130), // Increased width
          5: FixedColumnWidth(160),
          6: FlexColumnWidth(1.8), // Reduced width
          7: FixedColumnWidth(250),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AColors.borderLight)),
            ),
            children: List.generate(8, (index) {
              if (index == 5) {
                // "Passengers" column is not searchable
                return TableHeaderCell(
                  AStrings.passengers,
                  isSearching: false,
                  controller: TextEditingController(),
                  onTap: () {},
                );
              }

              final fieldKey = fieldKeys[index];

              return GestureDetector(
                onTap: () => onColumnTapped(index),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            titles[index],
                            textAlign: TextAlign.center,
                            style: ATextStyles.tableHeader.copyWith(
                              color: AColors.textPrimary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: headerControllers[index],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        getSortIcon(fieldKey),
                        size: 18,
                        color: AColors.textPrimary,
                      ),
                      onPressed: () {
                        sortProvider.toggleSortField(fieldKey);
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
