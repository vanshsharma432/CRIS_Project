import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/API.dart';
import 'package:flutter/material.dart';

class QuotaForwardForm extends StatefulWidget {
  final String accessToken;
  const QuotaForwardForm({required this.accessToken, super.key});

  @override
  State<QuotaForwardForm> createState() => _QuotaForwardFormState();
}

List<Map<String, dynamic>> trainData = [
  {
    "pnr": "2456789012",
    "totalPassengers": 5,
    "wlrcPassengers": 1,
    "sanctioned": TextEditingController(text: "10"),
    "eqWaiting": TextEditingController(text: "4"),
    "remarks": TextEditingController(),
  },
  {
    "pnr": "4315092764",
    "totalPassengers": 4,
    "wlrcPassengers": 2,
    "sanctioned": TextEditingController(text: "2"),
    "eqWaiting": TextEditingController(text: "5"),
    "remarks": TextEditingController(),
  },
  {
    "pnr": "6901348579",
    "totalPassengers": 4,
    "wlrcPassengers": 1,
    "sanctioned": TextEditingController(text: "3"),
    "eqWaiting": TextEditingController(text: "0"),
    "remarks": TextEditingController(),
  },
];

class _QuotaForwardFormState extends State<QuotaForwardForm> {
  String? selectedDivision;
  String? selectedDate;
  String? selectedTrainNo;
  String? selectedTrainFull;

  List<Map<String, String>> divisionList = [];
  List<String> trainOptions = []; // <-- Change this line
  List<Map<String, dynamic>> eqResults = [];

  bool isLoading = false;
  bool isTrainLoading = false;
  bool isDivisionLoading = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainList();
    _loadDivisions();
  }

  Future<void> _loadTrainList() async {
    setState(() => isTrainLoading = true);
    try {
      final result = await MRApiService.fetchTrainList();
      setState(() {
        trainOptions = result;
      });
    } catch (e) {
      setState(() => errorMessage = 'Train list error: $e');
    } finally {
      setState(() => isTrainLoading = false);
    }
  }

  Future<void> _loadDivisions() async {
    setState(() => isDivisionLoading = true);
    try {
      final result = await MRApiService.fetchDivisions(
        accessToken: widget.accessToken,
      );
      setState(() {
        divisionList = result;
      });
    } catch (e) {
      setState(() => errorMessage = 'Division load error: $e');
    } finally {
      setState(() => isDivisionLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _fetchEQ() async {
    if (selectedTrainNo == null ||
        selectedDate == null ||
        selectedDivision == null)
      return;

    setState(() {
      eqResults = [];
      errorMessage = null;
      isLoading = true;
    });

    try {
      final result = await MRApiService.fetchSentRequestsByMR(
        trainStartDate: selectedDate!,
        trainNo: selectedTrainNo!,
        divisionCode: selectedDivision!,
      );
      setState(() {
        eqResults = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Widget _divisionCell(String text, {bool highlight = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
          fontSize: 15,
          color: highlight ? const Color(0xFF2466B0) : Colors.black,
        ),
      ),
    ),
  );

  Widget _divisionRowCell(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );

  TextStyle get _tableCell => const TextStyle(fontSize: 15);

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Color(0xFF2466B0),
      ),
    ),
  );

  Widget _filterRow() {
    return Row(
      children: [
        Expanded(
          child: isDivisionLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: selectedDivision,
                  decoration: const InputDecoration(labelText: 'Division'),
                  items: divisionList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text("${e['value']!} - ${e['label']!}"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedDivision = val),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: "Start Date"),
              child: Text(selectedDate ?? 'Select'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isTrainLoading
              ? const CircularProgressIndicator()
              : DropdownSearch<String>(
                  items: trainOptions, // <-- Use the string list directly
                  selectedItem: selectedTrainFull,
                  onChanged: (val) {
                    setState(() {
                      selectedTrainFull = val;
                      selectedTrainNo = val?.split(" - ").first;
                    });
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: const InputDecoration(
                      labelText: "Train No",
                    ),
                  ),
                  popupProps: PopupProps.dialog(showSearchBox: true),
                ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed:
              (selectedDivision != null &&
                  selectedDate != null &&
                  selectedTrainNo != null)
              ? _fetchEQ
              : null,
          child: const Text("Fetch"),
        ),
      ],
    );
  }

  Widget _resultTable() {
    if (isLoading) return const CircularProgressIndicator();
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (eqResults.isEmpty) return const Text("No EQ Requests Found.");
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("PNR")),
          DataColumn(label: Text("Train Name")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("From")),
          DataColumn(label: Text("To")),
          DataColumn(label: Text("Division")),
          DataColumn(label: Text("Zone")),
          DataColumn(label: Text("Priority")),
          DataColumn(label: Text("Requested")),
          DataColumn(label: Text("Accepted")),
          DataColumn(label: Text("Remarks")),
        ],
        rows: eqResults
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text(e['pnr'] ?? '')),
                  DataCell(Text(e['trainName'] ?? '')),
                  DataCell(Text(e['trainStartDate'] ?? '')),
                  DataCell(Text(e['srcStation'] ?? '')),
                  DataCell(Text(e['destStation'] ?? '')),
                  DataCell(Text(e['assignedToDiv'] ?? '')),
                  DataCell(Text(e['assignedToZone'] ?? '')),
                  DataCell(Text(e['priorityName'] ?? '')),
                  DataCell(Text('${e['requestPassengers'] ?? ''}')),
                  DataCell(Text('${e['acceptedPassengers'] ?? ''}')),
                  DataCell(Text('${e['remarks'] ?? ''}')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget quotaStationWiseDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quota Station-wise Details",
                style: TextStyle(
                  color: Color(0xFF2466B0),
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 36,
                  dataRowMinHeight: 44,
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFFECF6FB),
                  ),
                  border: TableBorder(
                    top: const BorderSide(color: Color(0xFFC8D8E8)),
                    left: const BorderSide(color: Color(0xFFC8D8E8)),
                    right: const BorderSide(color: Color(0xFFC8D8E8)),
                    bottom: const BorderSide(color: Color(0xFFC8D8E8)),
                    horizontalInside: const BorderSide(
                      color: Color(0xFFE5EFFA),
                    ),
                    verticalInside: const BorderSide(color: Color(0xFFE5EFFA)),
                  ),
                  columns: [
                    DataColumn(label: _tableHeader("PNR")),
                    DataColumn(label: _tableHeader("Total Passengers")),
                    DataColumn(label: _tableHeader("WL/RC Passengers")),
                    DataColumn(label: _tableHeader("Sactioned")),
                    DataColumn(label: _tableHeader("EQ Waiting")),
                    DataColumn(label: _tableHeader("Remarks")),
                  ],
                  rows: eqResults
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(Text(e['pnr'] ?? '')),
                            DataCell(Text(e['totalPassengers'].toString() ?? '')),
                            DataCell(Text(e['waitingPassengers'].toString() ?? '')),
                            DataCell(Text(e['acceptedPassengers'].toString() ?? '')),
                            DataCell(Text(e['waitingPassengers'].toString() ?? '')),
                            DataCell(Text(e['remarks'] ?? '')),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColors.betterLightBlue,
      appBar: AppBar(
        backgroundColor: AColors.primary,
        title: const Text("EQ Request Viewer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterRow(),
            const SizedBox(height: 20),
            Expanded(child: _resultTable()),
            quotaStationWiseDetails(),
          ],
        ),
      ),
    );
  }
}
