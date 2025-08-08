import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';
import '../services/API.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';

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
  })
  onSubmit;

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

  final List<String> mpOptions = ['MP', 'Non-MP'];
  final List<String> statusOptions = ['Approved', 'Pending', 'Rejected'];

  List<String> trainList = [];
  bool isLoadingTrainList = true;

  @override
  void initState() {
    super.initState();
    _loadTrainList();
  }

  Future<void> _loadTrainList() async {
    final fetched = await MRApiService.fetchTrainList();
    setState(() {
      trainList = fetched;
      isLoadingTrainList = false;
    });
  }

  Future<void> _pickDate({
    required DateTime? currentDate,
    required ValueChanged<DateTime> onDatePicked,
  }) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? today,
      firstDate: today.subtract(const Duration(days: 10)),
      lastDate: today.add(const Duration(days: 120)),
    );
    if (picked != null) onDatePicked(picked);
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onPicked,
  ) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => _pickDate(currentDate: value, onDatePicked: onPicked),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: ATextStyles.bodyText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          child: Text(
            value != null
                ? DateFormat('dd MMM yyyy').format(value)
                : AStrings.selectPrompt,
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
      width: 140,
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: ATextStyles.bodyText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
    );
  }

  void _handleSubmit() async {
    final bool hasJourneyDate = journeyDate != null;
    final bool hasStartDate = startDate != null;

    final bool hasAtLeastOneFilter = [
      selectedDivision,
      selectedZone,
      selectedMp,
      selectedStatus,
      selectedTrainNo,
    ].any((val) => val != null && val.isNotEmpty);

    if (hasJourneyDate && hasStartDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select only one: Journey Date or Train Start Date.",
          ),
        ),
      );
      return;
    }

    if (!hasJourneyDate && !hasStartDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select either Journey Date or Train Start Date.",
          ),
        ),
      );
      return;
    }

    if (!hasAtLeastOneFilter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select at least one filter: Division, Zone, User Type, Status, or Train No.",
          ),
        ),
      );
      return;
    }

    final journeyDateStr = journeyDate != null
        ? DateFormat('yyyy-MM-dd').format(journeyDate!)
        : null;
    final startDateStr = startDate != null
        ? DateFormat('yyyy-MM-dd').format(startDate!)
        : null;

    final fetchedData = await MRApiService.fetchZoneRequests(
      trainStartDate: startDateStr,
      journeyDate: journeyDateStr,
      trainNo: selectedTrainNo,
      divisionCode: selectedDivision,
      zoneCode: selectedZone,
    );

    widget.onSubmit(
      selectedDate: journeyDate ?? startDate!,
      dateType: journeyDate != null ? 'journeyDate' : 'trainStartDate',
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
    final trainNoOptions = trainList;
    final filterProvider = Provider.of<FilterProvider>(context);
    final List<String> divisions = filterProvider.divisionList
        .map((d) => d['divCode'] as String)
        .toList();
    final List<String> zones = filterProvider.zoneList
        .map((z) => z['zoneCode'] as String)
        .toList();

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
                isCollapsed
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
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
                _buildDateField(AStrings.journeyDate, journeyDate, (val) {
                  setState(() {
                    journeyDate = val;
                    startDate = null;
                  });
                }),

                Container(margin: EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 0),width: 1, height: 45, color: AColors.gray),
                _buildDropdownField(
                  label: AStrings.division,
                  value: selectedDivision,
                  options: divisions,
                  onChanged: (val) {
                    setState(() {
                      selectedDivision = val;
                    });
                  },
                ),
                _buildDropdownField(
                  label: AStrings.zone,
                  value: selectedZone,
                  options: zones,
                  onChanged: (val) {
                    setState(() {
                      selectedZone = val;
                    });
                  },
                ),
                _buildDropdownField(
                  label: AStrings.userType,
                  value: selectedMp,
                  options: mpOptions,
                  onChanged: (val) {
                    setState(() {
                      selectedMp = val;
                    });
                  },
                ),
                _buildDropdownField(
                  label: AStrings.status,
                  value: selectedStatus,
                  options: statusOptions,
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val;
                    });
                  },
                ),
                isLoadingTrainList
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 150,
                        child: DropdownSearch<String>(
                          items: trainNoOptions, // e.g. ["12596", "12597"]
                          selectedItem: selectedTrainNo,
                          onChanged: (val) =>
                              setState(() => selectedTrainNo = val),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: AStrings.trainNo,
                              labelStyle: ATextStyles.bodyText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search Train No',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AStrings.submit,
                    style: ATextStyles.buttonText.copyWith(
                      color: AColors.white,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _handleRefresh,
                  icon: Icon(
                    Icons.refresh,
                    size: 20,
                    color: AColors.brandeisBlue,
                  ),
                  label: Text(
                    "Refresh",
                    style: ATextStyles.buttonText.copyWith(
                      color: AColors.brandeisBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AColors.brandeisBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                  onPressed: widget.startIndex <= 0
                      ? null
                      : widget.onPreviousPage,
                  tooltip: 'Previous Page',
                ),
                Text(
                  'Showing ${widget.startIndex + 1}–${widget.endIndex} of ${widget.totalCount}',
                  style: ATextStyles.bodySmall.copyWith(color: AColors.gray),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: widget.endIndex >= widget.totalCount
                      ? null
                      : widget.onNextPage,
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
