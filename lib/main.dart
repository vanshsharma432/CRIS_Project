import 'package:flutter/material.dart';

import 'models/train_request_model.dart';
import 'data/sample_data.dart';

import 'widgets/train_request_card.dart';
import 'widgets/select_columns_widget.dart';
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
  List<String> selectedColumns = List.from(AStrings.allColumns);
  bool isPreScreenSubmitted = false;

  @override
  void initState() {
    super.initState();
    selectedColumns = List.from(AStrings.allColumns);
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

    // You can use these submitted values as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AStrings.dashboardTitle),
      ),
      body: Column(
        children: [
          /// ✅ PreScreenBar shown always
          PreScreenBar(onSubmit: _onPreScreenSubmit),

          if (isPreScreenSubmitted)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 600;

                  return Column(
                    children: [
                      if (isDesktop) const DesktopHeaderRow(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: trainRequests.length,
                          itemBuilder: (context, index) {
                            final request = trainRequests[index];

                            return TrainRequestCard(
                              request: request,
                              onSelectionChanged: (bool? newValue) {
                                setState(() {
                                  final updated = request.copyWith(isSelected: newValue ?? false);
                                  _updateTrainRequest(updated);
                                });
                              },
                              onPriorityChanged: (int newPriority) {
                                setState(() {
                                  final updated = request.copyWith(priority: newPriority);
                                  _updateTrainRequest(updated);
                                });
                              },
                              onRejected: () {
                                setState(() {
                                  final updated = request.copyWith(currentStatus: "Rejected");
                                  _updateTrainRequest(updated);
                                });
                              },
                            );
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

  void _updateTrainRequest(TrainRequest updated) {
    final indexInMain = trainRequests.indexWhere((r) => r.pnr == updated.pnr);
    if (indexInMain != -1) {
      trainRequests[indexInMain] = updated;
    }
  }
}
