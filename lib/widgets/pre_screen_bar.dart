import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';

class PreScreenBar extends StatefulWidget {
  final void Function({
  required DateTime selectedDate,
  required String dateType,
  String? division,
  String? zone,
  String? mpInvolvement,
  }) onSubmit;

  const PreScreenBar({super.key, required this.onSubmit});

  @override
  State<PreScreenBar> createState() => _PreScreenBarState();
}

class _PreScreenBarState extends State<PreScreenBar> {
  DateTime? journeyDate;
  DateTime? startDate;
  String? selectedDivision;
  String? selectedZone;
  String? selectedMp;
  bool isCollapsed = false;

  final List<String> divisions = ['NDLS', 'LKO', 'UMB', 'BPL'];
  final List<String> zones = ['NR', 'WR', 'ER', 'SR'];
  final List<String> mpOptions = ['MP', 'Non-MP'];

  Future<void> _pickDate({
    required DateTime? currentDate,
    required ValueChanged<DateTime> onDatePicked,
  }) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? today,
      firstDate: today.subtract(const Duration(days: 5)),
      lastDate: today.add(const Duration(days: 120)),
    );
    if (picked != null) onDatePicked(picked);
  }

  Widget _buildDateField(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    return Expanded(
      child: InkWell(
        onTap: () => _pickDate(currentDate: value, onDatePicked: onPicked),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: ATextStyles.bodyText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            value != null ? DateFormat('dd MMM yyyy').format(value) : AStrings.selectPrompt,
            style: ATextStyles.bodyText,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: ATextStyles.bodyText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AColors.shadow, blurRadius: 6)],
      ),
      child: Row(
        children: [
          _buildDateField(AStrings.trainStartDate, startDate, (val) {
            setState(() {
              startDate = val;
              journeyDate = null;
            });
          }),
          const SizedBox(width: 8),
          Text(AStrings.or, style: ATextStyles.bodyText),
          const SizedBox(width: 8),
          _buildDateField(AStrings.journeyDate, journeyDate, (val) {
            setState(() {
              journeyDate = val;
              startDate = null;
            });
          }),
          const SizedBox(width: 16),
          const VerticalDivider(thickness: 1, width: 32),
          _buildDropdownField(
            label: AStrings.division,
            value: selectedDivision,
            options: divisions,
            onChanged: (val) {
              setState(() {
                selectedDivision = val;
                selectedZone = null;
                selectedMp = null;
              });
            },
          ),
          const SizedBox(width: 8),
          Text(AStrings.or, style: ATextStyles.bodyText),
          const SizedBox(width: 8),
          _buildDropdownField(
            label: AStrings.zone,
            value: selectedZone,
            options: zones,
            onChanged: (val) {
              setState(() {
                selectedZone = val;
                selectedDivision = null;
                selectedMp = null;
              });
            },
          ),
          const SizedBox(width: 8),
          Text(AStrings.or, style: ATextStyles.bodyText),
          const SizedBox(width: 8),
          _buildDropdownField(
            label: AStrings.userType,
            value: selectedMp,
            options: mpOptions,
            onChanged: (val) {
              setState(() {
                selectedMp = val;
                selectedDivision = null;
                selectedZone = null;
              });
            },
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: Text(AStrings.submit, style: ATextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildDateField(AStrings.trainStartDate, startDate, (val) {
                setState(() {
                  startDate = val;
                  journeyDate = null;
                });
              }),
              const SizedBox(width: 8),
              Text(AStrings.or, style: ATextStyles.bodyText),
              const SizedBox(width: 8),
              _buildDateField(AStrings.journeyDate, journeyDate, (val) {
                setState(() {
                  journeyDate = val;
                  startDate = null;
                });
              }),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _buildDropdownField(
                label: AStrings.division,
                value: selectedDivision,
                options: divisions,
                onChanged: (val) {
                  setState(() {
                    selectedDivision = val;
                    selectedZone = null;
                    selectedMp = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(AStrings.or, style: ATextStyles.bodyText),
              const SizedBox(width: 8),
              _buildDropdownField(
                label: AStrings.zone,
                value: selectedZone,
                options: zones,
                onChanged: (val) {
                  setState(() {
                    selectedZone = val;
                    selectedDivision = null;
                    selectedMp = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(AStrings.or, style: ATextStyles.bodyText),
              const SizedBox(width: 8),
              _buildDropdownField(
                label: AStrings.userType,
                value: selectedMp,
                options: mpOptions,
                onChanged: (val) {
                  setState(() {
                    selectedMp = val;
                    selectedDivision = null;
                    selectedZone = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: Text(AStrings.submit, style: ATextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final selectedDate = journeyDate ?? startDate;
    final selectedDateType = journeyDate != null ? AStrings.journeyDate : AStrings.trainStartDate;

    if (selectedDate == null ||
        (selectedDivision == null && selectedZone == null && selectedMp == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AStrings.fillFieldsError)),
      );
      return;
    }

    widget.onSubmit(
      selectedDate: selectedDate,
      dateType: selectedDateType,
      division: selectedDivision,
      zone: selectedZone,
      mpInvolvement: selectedMp,
    );

    setState(() => isCollapsed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.edit, size: 18),
            label: Text(AStrings.editOptions, style: ATextStyles.bodyText),
            onPressed: () => setState(() => isCollapsed = false),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 600
            ? _buildDesktopLayout()
            : _buildMobileLayout();
      },
    );
  }
}
