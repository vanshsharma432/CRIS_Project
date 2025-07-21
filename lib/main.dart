import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/train_request_model.dart';
import 'data/sample_data.dart';
import 'providers/sort_provider.dart';
import 'providers/filter_provider.dart';
import 'widgets/train_request_list_view.dart';
import 'widgets/pre_screen_bar.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';
import 'constants/strings.dart';
import 'widgets/train_request_card_parts.dart';
import 'widgets/login.dart';
import 'services/API.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SortProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()), // <-- Add this line
      ],
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
      home: const LoginScreen(),
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

  List<TrainRequest> _apiTrainRequests = [];

  bool isPreScreenSubmitted = false;
  int? activeSearchColumn;

  int currentPage = 0;
  final int itemsPerPage = 20;

  int startIndex = 0;
  int endIndex = 0;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    for (var controller in _headerSearchControllers) {
      controller.addListener(() => setState(() {}));
    }
    _fetchMRRequests(); // Trigger initial load
  }

  List<TrainRequest> get filteredRequests {
    final sourceList = _apiTrainRequests.isNotEmpty ? _apiTrainRequests : trainRequests;

    return sourceList.where((request) {
      return request.pnr.toString().contains(_headerSearchControllers[0].text) &&
          request.trainStartDate.toString().contains(_headerSearchControllers[1].text) &&
          request.trainNo.toString().contains(_headerSearchControllers[2].text) &&
          request.division.toLowerCase().contains(_headerSearchControllers[3].text.toLowerCase()) &&
          request.requestedBy.toLowerCase().contains(_headerSearchControllers[5].text.toLowerCase()) &&
          request.currentStatus.toLowerCase().contains(_headerSearchControllers[6].text.toLowerCase());
    }).toList();
  }

  Future<void> _fetchMRRequests() async {
  try {
    final apiData = await MRApiService.fetchSentRequestsByMR(
      trainJourneyDate: '2025-07-02',
      trainStartDate: '2025-07-02',
      zoneCode: 'NE',
      divisionCode: 'UMB',
      userId: '186',
      trainNo: '12304',
    );

    _onPreScreenSubmit(
      dateType: 'trainStartDate',
      selectedDate: DateTime.parse('2025-07-02'),
      division: 'UMB',
      zone: 'NE',
      trainNo: '12304',
      apiData: apiData,
    );
  } catch (e) {
    debugPrint('Failed to fetch MR requests: $e');
  }
}


  void _onPreScreenSubmit({
    required String dateType,
    required DateTime selectedDate,
    String? division,
    String? zone,
    String? mpInvolvement,
    String? status,
    String? trainNo,
    List<Map<String, dynamic>>? apiData,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isPreScreenSubmitted = true;
          currentPage = 0;

          // Convert API data to TrainRequest model
          if (apiData != null && apiData.isNotEmpty) {
            _apiTrainRequests = apiData.map((json) => TrainRequest.fromJson(json)).toList();
          } else {
            _apiTrainRequests = [];
          }
        });
      }
    });
  }

  void _onPreScreenRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isPreScreenSubmitted = true;
          currentPage = 0;
          _apiTrainRequests.clear();

          for (var controller in _headerSearchControllers) {
            controller.clear();
          }
        });
      }
    });
  }

  void _updateTrainRequest(TrainRequest updated) {
    final indexInMain = trainRequests.indexWhere((r) => r.pnr == updated.pnr);
    if (indexInMain != -1) {
      trainRequests[indexInMain] = updated;
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  void _goToNextPage() {
    final totalPages = (totalCount / itemsPerPage).ceil();
    if (currentPage < totalPages - 1) {
      setState(() => currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);

    final sortedRequests = [...filteredRequests]..sort(sortProvider.compare);

    totalCount = sortedRequests.length;
    startIndex = currentPage * itemsPerPage;
    endIndex = (startIndex + itemsPerPage).clamp(0, totalCount);
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
            onPreviousPage: _goToPreviousPage,
            onNextPage: _goToNextPage,
            startIndex: startIndex,
            endIndex: endIndex,
            totalCount: totalCount,
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
                              activeSearchColumn = activeSearchColumn == index ? null : index;
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
                          onUpdate: _updateTrainRequest,
                          onPaginationChanged: ({
                            required int startIndex,
                            required int endIndex,
                            required int totalCount,
                          }) {
                            if (mounted) {
                              setState(() {
                                this.startIndex = startIndex;
                                this.endIndex = endIndex;
                                this.totalCount = totalCount;
                              });
                            }
                          },
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
