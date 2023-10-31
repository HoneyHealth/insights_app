import 'package:flutter/material.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insight_widget.mobile.dart';
import 'insight_widget.desktop.dart';

class InsightWidget extends StatefulWidget {
  final String userId;
  final Insight insight;

  const InsightWidget(this.userId, this.insight, {super.key});

  @override
  State<InsightWidget> createState() => _InsightWidgetState();
}

class _InsightWidgetState extends State<InsightWidget> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.insight.comment ?? "";
  }

  @override
  void didUpdateWidget(InsightWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insight != widget.insight) {
      _commentController.text = widget.insight.comment ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => InsightMobileWidget(
        userId: widget.userId,
        insight: widget.insight,
        commentController: _commentController,
        generateColumns: _generateColumns,
        generateRows: _generateRows,
      ),
      desktop: (_) => InsightDesktopWidget(
        userId: widget.userId,
        insight: widget.insight,
        commentController: _commentController,
        generateColumns: _generateColumns,
        generateRows: _generateRows,
      ),
    );
  }

  List<DataColumn> _generateColumns(Map<String, dynamic> sourceData) {
    var columns = [const DataColumn(label: Text(''))];
    columns.addAll(sourceData.keys.map((key) => DataColumn(label: Text(key))));
    return columns;
  }

  List<DataRow> _generateRows(Map<String, dynamic> sourceData) {
    if (sourceData.isEmpty) return [];

    var firstEntry = sourceData.entries.first.value as Map<String, dynamic>;
    return firstEntry.keys.map((originalColumn) {
      var cells = [
        DataCell(
          Text(
            originalColumn,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ]; // Bolded the text
      cells.addAll(sourceData.entries.map((entry) {
        var value = (entry.value as Map<String, dynamic>)[originalColumn];
        return DataCell(Text(value.toString()));
      }).toList());

      return DataRow(cells: cells);
    }).toList();
  }
}
