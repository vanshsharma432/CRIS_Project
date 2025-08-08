import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/API.dart';

class QuotaForwardForm extends StatefulWidget {
  final String accessToken;
  const QuotaForwardForm({required this.accessToken, Key? key}) : super(key: key);

  @override
  State<QuotaForwardForm> createState() => _QuotaForwardFormState();
}

class _QuotaForwardFormState extends State<QuotaForwardForm> {
  String? selectedDivision;
  String? selectedTrainFull;

  List<String> divisionList = [];
  List<String> trainOptions = []; // <-- Change this line
  List<Map<String, dynamic>> eqResults = [];

  bool isLoading = false;
  bool isTrainLoading = false;
  bool isDivisionLoading = false;
  final _dateFormat = DateFormat('dd/MM/yy');
  DateTime? selectedDate;
  
  String? selectedTrainNo;

  // Dummy train data for dropdown
  final List<Map<String, String>> trainList = [
    {"trainNo": "12546", "trainName": "HWH DBRT EXPRESS"},
    {"trainNo": "12345", "trainName": "RAJDHANI EXPRESS"},
    {"trainNo": "15678", "trainName": "GUWAHATI EXP"},
    {"trainNo": "78965", "trainName": "KOLKATA MAIL"},
    {"trainNo": "14321", "trainName": "YNR EXPRESS"},
    {"trainNo": "12951", "trainName": "MUMBAI EXP"},
    {"trainNo": "22222", "trainName": "SUPERFAST AC"},
  ];
  Map<String, Map<String, int>> divisionClassEq = {
    'JSM': {'1A': 4, '2A': 2, '3A': 3, 'SL': 1},
    'DLI': {'1A': 1, '2A': 3, '3A': 5, 'SL': 2},
    'UMB': {'1A': 2, '2A': 1, '3A': 4, 'SL': 3},
  };

  // Table data
  final Map<String, Map<String, int>> divisionInfo = {
    'JSM': {'Total EQ': 4, 'Used EQ': 2, 'Balance EQ': 11},
    'DLI': {'Total EQ': 5, 'Used EQ': 3, 'Balance EQ': 11},
    'UMB': {'Total EQ': 0, 'Used EQ': 0, 'Balance EQ': 22},
  };
  final List<String> divisionOrder = ['JSM', 'DLI', 'UMB'];
  final List<String> eqRows = ['Total EQ', 'Used EQ', 'Balance EQ'];

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

  @override
  void dispose() {
    for (final row in trainData) {
      row['sanctioned']?.dispose();
      row['eqWaiting']?.dispose();
      row['remarks']?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 820;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 900 : MediaQuery.of(context).size.width,
            ),
            child: Column(
              children: [
                // Card: Journey Inputs
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    color: const Color(0xFFF5F3FD),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Journey Date & Train Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2466B0),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              // Date dropdown
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await _pickDate(context);
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF2466B0),
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF2466B0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFB3CEE8),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      selectedDate == null
                                          ? "Select date"
                                          : _dateFormat.format(selectedDate!),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selectedDate == null
                                            ? Colors.grey[700]
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              // Train Number dropdown (MUST select, can't type freely)
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedTrainNo,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF2466B0),
                                  ),
                                  iconSize: 26,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.train,
                                      color: Color(0xFF2466B0),
                                    ),
                                    labelText: "Train Number",
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFB3CEE8),
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  items: trainList.map((train) {
                                    return DropdownMenuItem<String>(
                                      value: train['trainNo'],
                                      child: Text(
                                        "${train['trainNo']} - ${train['trainName']}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) {
                                    setState(() {
                                      selectedTrainNo = newVal;
                                    });
                                  },
                                  isExpanded: true,
                                  hint: const Text("Select train"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card: Division Info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 10,
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: const Color(0xFFB3CEE8),
                          width: 1,
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(120),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFECF6FB),
                            ),
                            children: [
                              const SizedBox(),
                              ...divisionOrder
                                  .map(
                                    (div) =>
                                        _divisionCell(div, highlight: true),
                                  )
                                  .toList(),
                            ],
                          ),
                          for (var row in eqRows)
                            TableRow(
                              decoration: BoxDecoration(
                                color: eqRows.indexOf(row) % 2 == 0
                                    ? const Color(0xFFF6FBFE)
                                    : Colors.white,
                              ),
                              children: [
                                _divisionRowCell(row),
                                ...divisionOrder
                                    .map(
                                      (div) => _divisionCell(
                                        '${divisionInfo[div]![row]}',
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card: Quota Station-wise Table (only if both selected)
                if (selectedDate != null && selectedTrainNo != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 17,
                        ),
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
                                  top: const BorderSide(
                                    color: Color(0xFFC8D8E8),
                                  ),
                                  left: const BorderSide(
                                    color: Color(0xFFC8D8E8),
                                  ),
                                  right: const BorderSide(
                                    color: Color(0xFFC8D8E8),
                                  ),
                                  bottom: const BorderSide(
                                    color: Color(0xFFC8D8E8),
                                  ),
                                  horizontalInside: const BorderSide(
                                    color: Color(0xFFE5EFFA),
                                  ),
                                  verticalInside: const BorderSide(
                                    color: Color(0xFFE5EFFA),
                                  ),
                                ),
                                columns: [
                                  DataColumn(label: _tableHeader("PNR")),
                                  DataColumn(
                                    label: _tableHeader("Total Passengers"),
                                  ),
                                  DataColumn(
                                    label: _tableHeader("WL/RC Passengers"),
                                  ),
                                  DataColumn(label: _tableHeader("Sanctioned")),
                                  DataColumn(label: _tableHeader("EQ Waiting")),
                                  DataColumn(label: _tableHeader("Remarks")),
                                ],
                                rows: List.generate(trainData.length, (i) {
                                  final row = trainData[i];
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                  'PNR Clicked',
                                                ),
                                                content: Text(
                                                  'You clicked on PNR: ${row['pnr']}',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Text(
                                            row['pnr'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2466B0),
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          row['totalPassengers'].toString(),
                                          style: _tableCell,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          row['wlrcPassengers'].toString(),
                                          style: _tableCell,
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 50,
                                          child: TextField(
                                            controller: row['sanctioned'],
                                            keyboardType: TextInputType.number,
                                            style: _tableCell,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 7,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5EFFA),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 50,
                                          child: TextField(
                                            controller: row['eqWaiting'],
                                            keyboardType: TextInputType.number,
                                            style: _tableCell,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 7,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5EFFA),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 128,
                                          child: TextField(
                                            controller: row['remarks'],
                                            maxLines: 2,
                                            maxLength: 50,
                                            style: _tableCell,
                                            decoration: InputDecoration(
                                              hintText: "Enter remarks",
                                              isDense: true,
                                              counterText: "",
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 10,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5EFFA),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
