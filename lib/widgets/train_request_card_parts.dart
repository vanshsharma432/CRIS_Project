import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart'; // ✅ Added'

/// 📅 Date Helpers
String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
String formatDateTime(DateTime date) => DateFormat('dd MMM yyyy hh:mm a').format(date);

/// 🟢 Table cell for desktop
class TableCellText extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;

  const TableCellText(
      this.text, {
        this.color,
        this.bold = false,
        super.key,
      });

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
        if (label.isNotEmpty)
          Text(label, style: ATextStyles.bodyBold),
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
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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


/// 🧩 Reusable table header row for desktop
class DesktopHeaderRow extends StatelessWidget {
  final int? activeSearchColumn;
  final List<TextEditingController> headerControllers;
  final void Function(int columnIndex) onColumnTapped;

  const DesktopHeaderRow({
    super.key,
    required this.activeSearchColumn,
    required this.headerControllers,
    required this.onColumnTapped,
  });

  @override
  Widget build(BuildContext context) {
    final titles = [
      AStrings.pnrJourney,
      AStrings.startDate,
      AStrings.trainInfo,
      AStrings.seatClass,
      AStrings.divisionZone,
      AStrings.passengers,
      AStrings.requestedBy,
      AStrings.status,
      '', // edit column
    ];

    return Container(
      color: AColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FixedColumnWidth(120),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FixedColumnWidth(160),
          6: FlexColumnWidth(2),
          7: FixedColumnWidth(100),
          8: FixedColumnWidth(150),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AColors.borderLight)),
            ),
            children: List.generate(8, (index) {
              // Edit column (skip)
              if (index == 7) return const SizedBox();

              // Passengers column – static, not searchable
              if (index == 4) {
                return TableHeaderCell(
                  AStrings.passengers,
                  isSearching: false,
                  controller: TextEditingController(),
                  onTap: () {},
                );
              }

              return TableHeaderCell(
                titles[index],
                isSearching: activeSearchColumn == index,
                controller: headerControllers[index],
                onTap: () => onColumnTapped(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}
