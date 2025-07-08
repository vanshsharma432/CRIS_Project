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
  const TableHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: ATextStyles.tableHeader,
      ),
    );
  }
}


/// 🧩 Reusable table header row for desktop
class DesktopHeaderRow extends StatelessWidget {
  const DesktopHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1),   // PNR + Journey Date
          1: FixedColumnWidth(120),// Start Date
          2: FlexColumnWidth(1),   // Train No + Route
          3: FlexColumnWidth(1),   // Division + Zone
          4: FixedColumnWidth(160),// Passenger Counts
          5: FlexColumnWidth(2),   // Requested By
          6: FixedColumnWidth(100),// Status
          7: FixedColumnWidth(150), // Edit
        },
        children: const [
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AColors.borderLight)),
            ),
            children: [
              TableHeaderCell(AStrings.pnrJourney),
              TableHeaderCell(AStrings.startDate),
              TableHeaderCell(AStrings.trainInfo),
              TableHeaderCell(AStrings.divisionZone),
              TableHeaderCell(AStrings.passengers),
              TableHeaderCell(AStrings.requestedBy),
              TableHeaderCell(AStrings.status),
              SizedBox(), // Edit column
            ],
          ),
        ],
      ),
    );
  }
}

