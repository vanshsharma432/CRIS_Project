import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/train_request_model.dart';
import 'data/sample_data.dart';
import 'providers/sort_provider.dart';
import 'widgets/train_request_list_view.dart';
import 'widgets/pre_screen_bar.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';
import 'constants/strings.dart';
import 'widgets/train_request_card_parts.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SortProvider(),
      child: const MyApp(),
    ),
  );
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
          titleTextStyle: ATextStyles.headingMedium.copyWith(color: AColors.white),
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
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<TextEditingController> _headerSearchControllers =
  List.generate(8, (_) => TextEditingController());

  bool isPreScreenSubmitted = false;
  int? activeSearchColumn;

  int currentPage = 0;
  final int itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    for (var controller in _headerSearchControllers) {
      controller.addListener(() => setState(() {}));
    }
  }

  List<TrainRequest> get filteredRequests {
    return trainRequests.where((request) {
      return request.pnr.toString().contains(_headerSearchControllers[0].text) &&
          request.trainStartDate.toString().contains(_headerSearchControllers[1].text) &&
          request.trainNo.toString().contains(_headerSearchControllers[2].text) &&
          request.division.toLowerCase().contains(_headerSearchControllers[3].text.toLowerCase()) &&
          request.requestedBy.toLowerCase().contains(_headerSearchControllers[5].text.toLowerCase()) &&
          request.currentStatus.toLowerCase().contains(_headerSearchControllers[6].text.toLowerCase());
    }).toList();
  }

  void _onPreScreenSubmit({
    required String dateType,
    required DateTime selectedDate,
    String? division,
    String? zone,
    String? mpInvolvement,
    String? status,
    String? trainNo,
  }) {
    setState(() {
      isPreScreenSubmitted = true;
    });
  }

  void _onPreScreenRefresh() {
    setState(() {
      currentPage = 0;
      for (var controller in _headerSearchControllers) {
        controller.clear();
      }
    });
  }

  void _updateTrainRequest(TrainRequest updated) {
    final indexInMain = trainRequests.indexWhere((r) => r.pnr == updated.pnr);
    if (indexInMain != -1) {
      trainRequests[indexInMain] = updated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);

    final sortedRequests = [...filteredRequests]..sort(sortProvider.compare);

    final visibleItems = sortedRequests.skip(startIndex).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AStrings.dashboardTitle),
      ),
      body: Column(
        children: [
          PreScreenBar(
            onSubmit: _onPreScreenSubmit,
            onRefresh: _onPreScreenRefresh,
          ),
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
                          startIndex: startIndex,
                          endIndex: endIndex,
                          totalCount: totalCount,
                          onColumnTapped: (index) {
                            setState(() {
                            });

                            final fieldMap = {
                              0: 'pnr',
                              1: 'trainStartDate',
                              2: 'trainNo',
                              3: 'division',
                              4: 'seatClass',
                              5: 'totalPassengers',
                              6: 'requestedBy',
                              7: 'currentStatus',
                            };

                            if (fieldMap.containsKey(index)) {
                              sortProvider.toggleSortField(fieldMap[index]!);
                            }
                          },
                        ),
                      Expanded(
                        child: TrainRequestListView(
                          allRequests: visibleItems,
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
}
