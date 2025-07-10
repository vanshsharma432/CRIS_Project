import 'package:flutter/material.dart';
import 'models/train_request_model.dart';
import 'data/sample_data.dart';
import 'widgets/train_request_card.dart';
import 'widgets/train_request_list_view.dart';
import 'widgets/select_columns_widget.dart';
import 'widgets/search_filter_row.dart';
import 'widgets/train_request_card_parts.dart';
import 'widgets/pre_screen_bar.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';
import 'constants/strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AColors.offWhite,
        primaryColor: AColors.primary,
        textTheme: TextTheme(
          titleLarge: ATextStyles.headingLarge,
          titleMedium: ATextStyles.headingMedium,
          bodyMedium: ATextStyles.bodyText,
          bodySmall: ATextStyles.bodySmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AColors.brandeisBlue,
          titleTextStyle:
              ATextStyles.headingMedium.copyWith(color: AColors.white),
          iconTheme: const IconThemeData(color: AColors.white),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(AColors.secondary),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key}); // ✅ fixed constructor

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pnrController = TextEditingController();
  final _trainNoController = TextEditingController();
  final _divisionController = TextEditingController();
  final _statusController = TextEditingController();
  final _requestedByController = TextEditingController();

  final List<TextEditingController> _headerSearchControllers =
      List.generate(8, (_) => TextEditingController()); // ✅ only one declaration

  List<String> selectedColumns = List.from(AStrings.allColumns);
  bool isPreScreenSubmitted = false;
  int? activeSearchColumn; // index of active heading being searched

  @override
  void initState() {
    super.initState();
      for (var controller in _headerSearchControllers) {
    controller.addListener(() => setState(() {}));
  }

    _pnrController.addListener(() => setState(() {}));
    _trainNoController.addListener(() => setState(() {}));
    _divisionController.addListener(() => setState(() {}));
    _statusController.addListener(() => setState(() {}));
    _requestedByController.addListener(() => setState(() {}));
  }

  List<TrainRequest> get filteredRequests {
    return trainRequests.where((request) {
      return request.pnr
              .toString()
              .contains(_headerSearchControllers[0].text) &&
          request.trainStartDate
              .toString()
              .contains(_headerSearchControllers[1].text) &&
          request.trainNo
              .toString()
              .contains(_headerSearchControllers[2].text) &&
          request.division
              .toLowerCase()
              .contains(_headerSearchControllers[3].text.toLowerCase()) &&
          request.requestedBy
              .toLowerCase()
              .contains(_headerSearchControllers[5].text.toLowerCase()) &&
          request.currentStatus
              .toLowerCase()
              .contains(_headerSearchControllers[6].text.toLowerCase());
      // Skipping columns 4 (passenger counts) and 7 (edit)
    }).toList();
  }

  void onColumnSelectionChanged(List<String> columns) {
    setState(() {
      selectedColumns = columns;
    });
  }

  void _onPreScreenSubmit({
    required String dateType,
    required DateTime selectedDate,
    String? division,
    String? zone,
    String? mpInvolvement,
  }) {
    setState(() {
      isPreScreenSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AStrings.dashboardTitle),
      ),
      body: Column(
        children: [
          PreScreenBar(onSubmit: _onPreScreenSubmit),

          if (isPreScreenSubmitted)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 600;

                  return Column(
                    children: [
                      if (isDesktop)
              DesktopHeaderRow(
                activeSearchColumn: activeSearchColumn,
                headerControllers: _headerSearchControllers,
                onColumnTapped: (index) {
                  setState(() {
                    activeSearchColumn = activeSearchColumn == index ? null : index;
                  });
                },
              ),

                      // Expanded(
                      //   child: ListView.builder(
                      //     itemCount: filteredRequests.length,
                      //     itemBuilder: (context, index) {
                      //       final request = filteredRequests[index];

                      //       return TrainRequestCard(
                      //         request: request,
                      //         onSelectionChanged: (bool? newValue) {
                      //           setState(() {
                      //             final updated = request.copyWith(
                      //                 isSelected: newValue ?? false);
                      //             _updateTrainRequest(updated);
                      //           });
                      //         },
                      //         onPriorityChanged: (int newPriority) {
                      //           setState(() {
                      //             final updated =
                      //                 request.copyWith(priority: newPriority);
                      //             _updateTrainRequest(updated);
                      //           });
                      //         },
                      //         onRejected: () {
                      //           setState(() {
                      //             final updated = request.copyWith(
                      //                 currentStatus: "Rejected");
                      //             _updateTrainRequest(updated);
                      //           });
                      //         },
                      //       );
                      //     },
                      //   ),
                      // ),
                      Expanded(
                        child: TrainRequestListView(
                          allRequests: filteredRequests,
                          onUpdate: (updated) => _updateTrainRequest(updated),
                        ),
                      ),

                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _updateTrainRequest(TrainRequest updated) {
    final indexInMain =
        trainRequests.indexWhere((r) => r.pnr == updated.pnr);
    if (indexInMain != -1) {
      trainRequests[indexInMain] = updated;
    }
  }
}
