import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';
import 'package:intl/intl.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FilterProvider>(context);
    final selectedField = provider.selectedField;

    return ExpansionTile(
      title: Text(AStrings.filterTitle, style: ATextStyles.heading),
      backgroundColor: AColors.offWhite,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      children: [
        // 🔽 Filter By label and dropdown vertically
        DropdownButton<String>(
          isExpanded: true,
          value: selectedField != null && selectedField.isNotEmpty
              ? selectedField
              : null,
          hint: Text(AStrings.selectFieldHint, style: ATextStyles.bodySmall),
          onChanged: (value) => provider.setSelectedField(value),
          items: provider.filterFields.map((field) {
            return DropdownMenuItem(
              value: field,
              child: Text(field, style: ATextStyles.bodySmall),
            );
          }).toList(),
        ),

        // 🔢 Conditional Inputs
        if (selectedField == AStrings.total ||
            selectedField == AStrings.requested ||
            selectedField == AStrings.accepted)
          _buildNumericInput(context, provider),

        if (selectedField == AStrings.currentStatus ||
            selectedField == AStrings.division ||
            selectedField == AStrings.zone ||
            selectedField == AStrings.remarksByRailways ||
            selectedField == AStrings.seatClass ||
            selectedField == AStrings.requestedByName)
          _buildTextSearchInput(context, provider),

        if (selectedField == AStrings.trainStartDate ||
            selectedField == AStrings.requestedOn)
          _buildDatePicker(context, provider),

        const SizedBox(height: 16),
        const Divider(),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.gray,
              foregroundColor: Colors.white,
            ),
            onPressed: () => provider.clearFilter(),
            label: Text(AStrings.resetFilter, style: ATextStyles.button),
          ),
        ),
      ],
    );
  }

  Widget _buildTextSearchInput(BuildContext context, FilterProvider provider) {
    return TextField(
      decoration: InputDecoration(
        labelText: AStrings.enterSearchValue,
        border: const OutlineInputBorder(),
      ),
      style: ATextStyles.bodySmall,
      onChanged: (value) => provider.setFilterValue(value),
    );
  }

  Widget _buildNumericInput(BuildContext context, FilterProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: AStrings.minValue,
              border: const OutlineInputBorder(),
            ),
            style: ATextStyles.bodySmall,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final current =
                  provider.filterValue as Map<String, String>? ?? {};
              provider.setFilterValue({...current, 'min': value});
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: AStrings.maxValue,
              border: const OutlineInputBorder(),
            ),
            style: ATextStyles.bodySmall,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final current =
                  provider.filterValue as Map<String, String>? ?? {};
              provider.setFilterValue({...current, 'max': value});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, FilterProvider provider) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today, size: 18),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AColors.primary,
        ),
        label: Text(AStrings.pickDate, style: ATextStyles.button),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (picked != null) {
            final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
            provider.setFilterValue(formattedDate);
          }
        },
      ),
    );
  }
}
