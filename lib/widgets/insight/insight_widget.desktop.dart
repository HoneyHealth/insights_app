import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/material.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/insight/widgets/source_functions_list.dart';

import 'widgets/insight_details_widget.dart';
import 'previous_insights/previous_insight_widget.dart';

class InsightDesktopWidget extends StatelessWidget {
  final String userId;
  final Insight insight;

  final TextEditingController _commentController;

  final List<DataColumn> Function(Map<String, dynamic> sourceData)
      _generateColumns;
  final List<DataRow> Function(Map<String, dynamic> sourceData) _generateRows;

  const InsightDesktopWidget({
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
    return LayoutBuilder(
      builder: (context, constraints) => HorizontalSplitPane(
        constraints: constraints,
        separatorColor: Theme.of(context).dividerColor,
        separatorThickness: 4.0,
        fractions: const [0.5, 0.5],
        children: [
          SingleChildScrollView(
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
                  const SizedBox(height: 24), // Spacing

                  if (insight.previousInsights.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Previous Insights',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust the height as needed
                      child: SingleChildScrollView(
                        // A scrollable list of PreviousInsightWidgets
                        child: Column(
                          children: insight.previousInsights
                              .map((previousInsight) => PreviousInsightWidget(previousInsight: previousInsight))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 132,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: SourceFunctionsList(
                insight: insight,
                generateColumns: _generateColumns,
                generateRows: _generateRows,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
