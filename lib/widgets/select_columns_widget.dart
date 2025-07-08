import 'package:flutter/material.dart';

class SelectColumnsWidget extends StatefulWidget {
  final List<String> allColumns;
  final List<String> selectedColumns;
  final Function(List<String>) onSelectionChanged;

  const SelectColumnsWidget({
    super.key,
    required this.allColumns,
    required this.selectedColumns,
    required this.onSelectionChanged,
  });

  @override
  State<SelectColumnsWidget> createState() => _SelectColumnsWidgetState();
}

class _SelectColumnsWidgetState extends State<SelectColumnsWidget> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = [...widget.selectedColumns];
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Select Columns to Display'),
      children: widget.allColumns.map((col) {
        return CheckboxListTile(
          value: tempSelected.contains(col),
          title: Text(col),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                tempSelected.add(col);
              } else {
                tempSelected.remove(col);
              }
              widget.onSelectionChanged(tempSelected);
            });
          },
        );
      }).toList(),
    );
  }
}
