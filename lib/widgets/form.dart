import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'services.dart';

class QuotaForwardForm extends StatefulWidget {
  final String accessToken;
  const QuotaForwardForm({required this.accessToken, Key? key}) : super(key: key);

  @override
  State<QuotaForwardForm> createState() => _QuotaForwardFormState();
}

class _QuotaForwardFormState extends State<QuotaForwardForm> {
  String? selectedDivision;
  String? selectedDate;
  String? selectedTrainNo;
  String? selectedTrainFull;

  List<Map<String, String>> divisionList = [];
  List<Map<String, dynamic>> trainOptions = [];
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
      final result = await QuotaService.fetchTrainList(accessToken: widget.accessToken);
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
      final result = await QuotaService.fetchDivisions(accessToken: widget.accessToken);
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
    if (selectedTrainNo == null || selectedDate == null || selectedDivision == null) return;

    setState(() {
      eqResults = [];
      errorMessage = null;
      isLoading = true;
    });

    try {
      final result = await QuotaService.fetchEQRequests(
        accessToken: widget.accessToken,
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

  Widget _filterRow() {
    return Row(children: [
      Expanded(
        child: isDivisionLoading
            ? const CircularProgressIndicator()
            : DropdownButtonFormField<String>(
                value: selectedDivision,
                decoration: const InputDecoration(labelText: 'Division'),
                items: divisionList
                    .map((e) =>
                        DropdownMenuItem(value: e['value'], child: Text(e['label']!)))
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
                items: trainOptions
                    .map((e) => "${e['trainNo']} - ${e['trainName'] ?? ''}")
                    .toList(),
                selectedItem: selectedTrainFull,
                onChanged: (val) {
                  setState(() {
                    selectedTrainFull = val;
                    selectedTrainNo = val?.split(" - ").first;
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: const InputDecoration(labelText: "Train No"),
                ),
                popupProps: PopupProps.dialog(showSearchBox: true),
              ),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: (selectedDivision != null &&
                selectedDate != null &&
                selectedTrainNo != null)
            ? _fetchEQ
            : null,
        child: const Text("Fetch"),
      )
    ]);
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
            .map((e) => DataRow(cells: [
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
                ]))
            .toList(),
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
          ],
        ),
      ),
    );
  }
}
