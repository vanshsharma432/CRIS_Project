import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../services/API.dart';

class QuotaForwardForm extends StatefulWidget {
  final String accessToken;
  const QuotaForwardForm({required this.accessToken, Key? key})
    : super(key: key);

  @override
  _QuotaForwardFormState createState() => _QuotaForwardFormState();
}

class _QuotaForwardFormState extends State<QuotaForwardForm> {
  String? selectedDate;
  String? selectedTrain;
  String? selectedClass;
  final NumberFormat numFormat = NumberFormat.decimalPattern('en_IN');

  List<String> trainOptions = [];
  bool isTrainListLoading = false;

  List<String> classList = ['1A', '2A', '3A', 'SL'];
  List<String> divList = ['JSM', 'DLI', 'UMB'];
  List<String> priorityList = ['High', 'Medium', 'Low'];

  Map<String, Map<String, int>> divisionClassEq = {
    'JSM': {'1A': 4, '2A': 2, '3A': 3, 'SL': 1},
    'DLI': {'1A': 1, '2A': 3, '3A': 5, 'SL': 2},
    'UMB': {'1A': 2, '2A': 1, '3A': 4, 'SL': 3},
  };

  List<Map<String, dynamic>> trainData = [
    {
      "pnr": "2456789012",
      "class": "1A",
      "priority": "High",
      "totalPassengers": 5,
      "wlrcPassengers": 1,
      "sanctioned": TextEditingController(text: "10"),
      "eqWaiting": TextEditingController(text: "4"),
      "remarks": TextEditingController(),
      "selectedDivision": "JSM",
    },
    {
      "pnr": "4315092764",
      "class": "2A",
      "priority": "Medium",
      "totalPassengers": 4,
      "wlrcPassengers": 2,
      "sanctioned": TextEditingController(text: "2"),
      "eqWaiting": TextEditingController(text: "5"),
      "remarks": TextEditingController(),
      "selectedDivision": "DLI",
    },
    {
      "pnr": "6901348579",
      "class": "SL",
      "priority": "Low",
      "totalPassengers": 4,
      "wlrcPassengers": 1,
      "sanctioned": TextEditingController(text: "3"),
      "eqWaiting": TextEditingController(text: "0"),
      "remarks": TextEditingController(),
      "selectedDivision": "UMB",
    },
  ];

  bool get showRest =>
      selectedDate != null && selectedTrain != null && selectedClass != null;

  @override
  void initState() {
    super.initState();
    _fetchTrainList();
  }

  @override
  void dispose() {
    for (final row in trainData) {
      row["sanctioned"].dispose();
      row["eqWaiting"].dispose();
      row["remarks"].dispose();
    }
    super.dispose();
  }

  Future<void> _fetchTrainList() async {
    setState(() => isTrainListLoading = true);
    try {
      final trains = await MRApiService.fetchTrainList();
      setState(() {
        trainOptions = trains;
        isTrainListLoading = false;
      });
    } catch (e) {
      setState(() => isTrainListLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load train list: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AColors.primary,
            onPrimary: AColors.white,
            surface: AColors.white,
            onSurface: AColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yy').format(picked);
      });
    }
  }

  InputDecoration _inputDeco(String hint, {bool max = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: ATextStyles.caption,
      counterStyle: ATextStyles.caption,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: max ? 12 : 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AColors.borderLight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColors.betterLightBlue,
      appBar: AppBar(
        backgroundColor: AColors.brandeisBlue,
        title: Text(
          'IREQMS',
          style: ATextStyles.headingMedium.copyWith(color: AColors.white),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AColors.shadow, blurRadius: 8)],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Train Start Date"),
                  const SizedBox(height: 12),
                  _journeyInputs(),
                  if (showRest) ...[
                    const SizedBox(height: 24),
                    _sectionTitle("Division Info"),
                    const SizedBox(height: 8),
                    _divisionInfoTable(),
                    const SizedBox(height: 28),
                    _sectionTitle("Quota Station-wise Details"),
                    const SizedBox(height: 12),
                    _quotaStationWiseTable(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: ATextStyles.headingMedium);

  Widget _journeyInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: AColors.primary,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedDate ?? 'Select Date',
                    style: ATextStyles.bodyText.copyWith(
                      color: selectedDate == null
                          ? AColors.gray
                          : AColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isTrainListLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSearch<String>(
                      items: trainOptions,
                      selectedItem: selectedTrain,
                      onChanged: (val) => setState(() => selectedTrain = val),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Train",
                          prefixIcon: const Icon(
                            Icons.train,
                            color: AColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      popupProps: PopupProps.dialog(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: ATextStyles.bodyText,
                          decoration: InputDecoration(
                            hintText: "Search train...",
                            hintStyle: ATextStyles.bodySmall,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedClass,
                items: classList
                    .map(
                      (cls) => DropdownMenuItem(value: cls, child: Text(cls)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedClass = val),
                decoration: InputDecoration(
                  labelText: "Class",
                  prefixIcon: const Icon(
                    Icons.event_seat,
                    color: AColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<DataRow> _buildRows(BuildContext context) {
    return trainData.asMap().entries.map((entry) {
      final rowIndex = entry.key;
      final row = entry.value;

      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 100,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        "PNR Clicked",
                        style: ATextStyles.headingMedium,
                      ),
                      content: Text('You clicked on PNR: ${row['pnr']}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  row['pnr'],
                  style: ATextStyles.bodyText.copyWith(
                    color: AColors.brandeisBlue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          DataCell(
            _InlineDropdown(
              value: row['class'],
              items: classList,
              onChanged: (val) =>
                  setState(() => trainData[rowIndex]['class'] = val),
              style: ATextStyles.bodyText,
              width: 65,
            ),
          ),
          DataCell(
            _InlineDropdown(
              value: row['priority'],
              items: priorityList,
              onChanged: (val) =>
                  setState(() => trainData[rowIndex]['priority'] = val),
              style: ATextStyles.bodyText,
              width: 75,
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                row['totalPassengers'].toString(),
                style: ATextStyles.tableCell,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                row['wlrcPassengers'].toString(),
                style: ATextStyles.tableCell,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: TextField(
                controller: row['sanctioned'],
                decoration: _inputDeco("Sanctioned"),
                style: ATextStyles.bodyText,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: TextField(
                controller: row['eqWaiting'],
                decoration: _inputDeco("Waiting"),
                style: ATextStyles.bodyText,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 140,
              child: TextField(
                controller: row['remarks'],
                maxLength: 50,
                maxLines: 2,
                decoration: _inputDeco("Enter remarks", max: true),
                style: ATextStyles.bodyText,
              ),
            ),
          ),
          DataCell(
            _InlineDropdown(
              value: row['selectedDivision'],
              items: divList,
              onChanged: (val) =>
                  setState(() => trainData[rowIndex]['selectedDivision'] = val),
              style: ATextStyles.bodyText,
              width: 70,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _divisionInfoTable() {
    return Container(
      decoration: BoxDecoration(
        color: AColors.betterLightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AColors.borderLight),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 80),
              ...divList.map(
                (div) => Expanded(
                  flex: classList.length,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AColors.paleCyan,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(div, style: ATextStyles.bodyBold),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 80),
              ...divList.expand(
                (_) => classList.map(
                  (cls) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(cls, style: ATextStyles.caption),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Only a single row for "Total EQ"
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Center(
                  child: Text("Total EQ", style: ATextStyles.caption),
                ),
              ),
              ...divList.expand(
                (div) => classList.map(
                  (cls) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (divisionClassEq[div]?[cls] ?? "-").toString(),
                        style: ATextStyles.bodyText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quotaStationWiseTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // child: ConstrainedBox(
      //   constraints: BoxConstraints(
      //     minWidth: MediaQuery.of(
      //       context,
      //     ).size.width, // Ensures table doesn't shrink too small
      //   ),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 12,
            dataRowMinHeight: 60,
            headingRowColor: MaterialStateProperty.all(AColors.betterLightBlue),
            border: TableBorder.all(color: AColors.borderLight),
            columns: [
              DataColumn(label: Text('PNR', style: ATextStyles.tableHeader)),
              DataColumn(label: Text('Class', style: ATextStyles.tableHeader)),
              DataColumn(
                label: Text('Priority', style: ATextStyles.tableHeader),
              ),
              DataColumn(
                label: Text(
                  'Total\nPassengers',
                  style: ATextStyles.tableHeader,
                ),
              ),
              DataColumn(
                label: Text(
                  'WL/RC\nPassengers',
                  style: ATextStyles.tableHeader,
                ),
              ),
              DataColumn(
                label: Text('Sanctioned', style: ATextStyles.tableHeader),
              ),
              DataColumn(
                label: Text('EQ Waiting', style: ATextStyles.tableHeader),
              ),
              DataColumn(
                label: Text('Remarks', style: ATextStyles.tableHeader),
              ),
              DataColumn(
                label: Text('Division', style: ATextStyles.tableHeader),
              ),
            ],
            rows: _buildRows(
              context,
            ), // Extract row building to separate method
          ),
        ),
      // ),
    );
  }
}

class _InlineDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final TextStyle? style;
  final double? width;

  const _InlineDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.style,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 90,
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        underline: SizedBox(),
        style: style,
        borderRadius: BorderRadius.circular(8),
        items: items
            .map(
              (v) => DropdownMenuItem<T>(
                value: v,
                child: Text(v.toString(), style: style),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: const Icon(
          Icons.arrow_drop_down,
          size: 18,
          color: AColors.primary,
        ),
      ),
    );
  }
}
