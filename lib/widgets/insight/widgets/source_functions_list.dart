import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/models/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SourceFunctionsList extends StatelessWidget {
  const SourceFunctionsList({
    super.key,
    required this.insight,
    required List<DataColumn> Function(Map<String, dynamic> sourceData)
        generateColumns,
    required List<DataRow> Function(Map<String, dynamic> sourceData)
        generateRows,
  })  : _generateColumns = generateColumns,
        _generateRows = generateRows;

  final Insight insight;
  final List<DataColumn> Function(Map<String, dynamic> sourceData)
      _generateColumns;
  final List<DataRow> Function(Map<String, dynamic> sourceData) _generateRows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          constraints: BoxConstraints(
            maxWidth: getValueForScreenType(
              context: context,
              mobile: 600,
              tablet: 900,
              desktop: 1200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              Text(
                "Source Functions:",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        for (var sourceFunction in insight.sourceFunctions) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            constraints: BoxConstraints(
              maxWidth: getValueForScreenType(
                context: context,
                mobile: 600,
                tablet: 900,
                desktop: 1200,
              ),
            ),
            child: PlatformListTile(
              title: Text(sourceFunction.name),
              // Add code here for Step 2
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _generateColumns(sourceFunction.sourceData),
                rows: _generateRows(sourceFunction.sourceData),
              ),
            ),
          )
        ],
        const SizedBox(
          height: 132,
        ),
      ],
    );
  }
}
