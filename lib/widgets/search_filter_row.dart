import 'package:dashboard_final/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/filter_provider.dart';

class SearchFilterRow extends StatelessWidget {
  final TextEditingController pnrController;
  final TextEditingController trainNoController;
  final TextEditingController divisionController;
  final TextEditingController statusController;
  final TextEditingController requestedByController;

  const SearchFilterRow({
    super.key,
    required this.pnrController,
    required this.trainNoController,
    required this.divisionController,
    required this.statusController,
    required this.requestedByController,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FixedColumnWidth(120),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FixedColumnWidth(160),
          5: FlexColumnWidth(2),
          6: FixedColumnWidth(100),
          7: FixedColumnWidth(150),
        },
        children: [
          TableRow(
            children: [
              _buildTextField(pnrController),
              const SizedBox(), // Start Date
              _buildTextField(trainNoController),
              _buildTextField(divisionController),
              const SizedBox(), // Passenger Counts
              _buildTextField(requestedByController),
              _buildTextField(statusController),
              const SizedBox(), // Edit
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Search',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
