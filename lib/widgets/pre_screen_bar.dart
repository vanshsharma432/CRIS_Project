import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';
import '../services/API.dart';

class PreScreenBar extends StatefulWidget {
  final void Function({
  required DateTime selectedDate,
  required String dateType,
  String? division,
  String? zone,
  String? mpInvolvement,
  String? status,
  String? trainNo,
  List<Map<String, dynamic>>? apiData,
  }) onSubmit;

  final VoidCallback? onRefresh;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  final int startIndex;
  final int endIndex;
  final int totalCount;

  const PreScreenBar({
    super.key,
    required this.onSubmit,
    required this.startIndex,
    required this.endIndex,
    required this.totalCount,
    this.onRefresh,
    this.onPreviousPage,
    this.onNextPage,
  });

  @override
  State<PreScreenBar> createState() => _PreScreenBarState();
}

class _PreScreenBarState extends State<PreScreenBar> {
  DateTime? journeyDate;
  DateTime? startDate;
  String? selectedDivision;
  String? selectedZone;
  String? selectedMp;
  String? selectedStatus;
  String? selectedTrainNo;
  bool isCollapsed = false;

  final List<String> divisions = ['NDLS', 'LKO', 'UMB', 'BPL'];
  final List<String> zones = ['NR', 'WR', 'ER', 'SR'];
  final List<String> mpOptions = ['MP', 'Non-MP'];
  final List<String> statusOptions = ['Approved', 'Pending', 'Rejected'];
  final List<String> trainNoOptions = ['12045', '12312', '22120', '22903'];

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
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => _pickDate(currentDate: value, onDatePicked: onPicked),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: ATextStyles.bodyText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
    return SizedBox(
      width: 130,
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

  void _handleSubmit() async {
    final selectedDate = journeyDate ?? startDate;
    final selectedDateType = journeyDate != null ? AStrings.journeyDate : AStrings.trainStartDate;

    if (selectedDate == null || selectedTrainNo == null || selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Train Start Date, Train No, and Division.")),
      );
      return;
    }

    // Format date to yyyy-MM-dd
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final fetchedData = await MRApiService.fetchZoneRequests(
      trainStartDate: formattedDate,
      trainNo: selectedTrainNo!,
      divisionCode: selectedDivision!,
    );

    widget.onSubmit(
      selectedDate: selectedDate,
      dateType: selectedDateType,
      division: selectedDivision,
      zone: selectedZone,
      mpInvolvement: selectedMp,
      status: selectedStatus,
      trainNo: selectedTrainNo,
      apiData: fetchedData,
    );
  }

  void _handleRefresh() {
    setState(() {
      journeyDate = null;
      startDate = null;
      selectedDivision = null;
      selectedZone = null;
      selectedMp = null;
      selectedStatus = null;
      selectedTrainNo = null;
    });

    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AColors.white,
        boxShadow: [BoxShadow(color: AColors.shadow, blurRadius: 6)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: AColors.gray,
              ),
              onPressed: () => setState(() => isCollapsed = !isCollapsed),
            ),
          ),
          if (!isCollapsed)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildDateField(AStrings.trainStartDate, startDate, (val) {
                  setState(() {
                    startDate = val;
                    journeyDate = null;
                  });
                }),
                Text(AStrings.or, style: ATextStyles.bodyText),
                _buildDateField(AStrings.journeyDate, journeyDate, (val) {
                  setState(() {
                    journeyDate = val;
                    startDate = null;
                  });
                }),
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
                Text(AStrings.or, style: ATextStyles.bodyText),
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
                Text(AStrings.or, style: ATextStyles.bodyText),
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
                Text(AStrings.or, style: ATextStyles.bodyText),
                _buildDropdownField(
                  label: AStrings.status,
                  value: selectedStatus,
                  options: statusOptions,
                  onChanged: (val) => setState(() => selectedStatus = val),
                ),
                Text(AStrings.or, style: ATextStyles.bodyText),
                _buildDropdownField(
                  label: AStrings.trainNo,
                  value: selectedTrainNo,
                  options: trainNoOptions,
                  onChanged: (val) => setState(() => selectedTrainNo = val),
                ),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(AStrings.submit, style: ATextStyles.buttonText.copyWith(color: AColors.white)),
                ),
                OutlinedButton.icon(
                  onPressed: _handleRefresh,
                  icon: Icon(Icons.refresh, size: 20, color: AColors.brandeisBlue),
                  label: Text("Refresh", style: ATextStyles.buttonText.copyWith(color: AColors.brandeisBlue)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AColors.brandeisBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: widget.startIndex <= 0 ? null : widget.onPreviousPage,
                  tooltip: 'Previous Page',
                ),
                Text(
                  '‹ Showing ${widget.startIndex + 1}–${widget.endIndex} of ${widget.totalCount} ›',
                  style: ATextStyles.bodySmall.copyWith(color: AColors.gray),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: widget.endIndex >= widget.totalCount ? null : widget.onNextPage,
                  tooltip: 'Next Page',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
