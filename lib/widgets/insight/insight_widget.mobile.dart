import 'package:flutter/material.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/insight/widgets/widgets.dart';

class InsightMobileWidget extends StatelessWidget {
  final String userId;
  final Insight insight;
  final TextEditingController _commentController;

  final List<DataColumn> Function(Map<String, dynamic> sourceData)
      _generateColumns;
  final List<DataRow> Function(Map<String, dynamic> sourceData) _generateRows;

  const InsightMobileWidget({
    super.key,
    required this.userId,
    required this.insight,
    required TextEditingController commentController,
    required List<DataColumn> Function(Map<String, dynamic> sourceData)
        generateColumns,
    required List<DataRow> Function(Map<String, dynamic> sourceData)
        generateRows,
  })  : _commentController = commentController,
        _generateColumns = generateColumns,
        _generateRows = generateRows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InsightDetailsWidget(
              insight: insight,
              userId: userId,
              commentController: _commentController,
            ),
            SourceFunctionsList(
              insight: insight,
              generateColumns: _generateColumns,
              generateRows: _generateRows,
            ),
            const SizedBox(
              height: 132,
            ),
          ],
        ),
      ),
    );
  }
}
