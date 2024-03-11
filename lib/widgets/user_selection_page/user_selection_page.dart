import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../insights_page.dart';
import '../widgets.dart';
import 'widgets/widgets.dart';

enum InsightFilter {
  launchReady,
  commented,
  fiveStar,
  flagged,
}

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  int? _sortColumnIndex; // Start with no column sorted
  bool _isAscending = true;

  final Map<InsightFilter, bool> _filters = {
    InsightFilter.launchReady: false,
    InsightFilter.commented: false,
    InsightFilter.fiveStar: false,
    InsightFilter.flagged: false,
  };

  void _onCardTap(InsightFilter filter) {
    setState(() {
      // Deselect all filters if the tapped filter is already selected
      if (_filters[filter]!) {
        _filters.updateAll((key, value) => false);
      } else {
        // Deselect the previously selected filter and select the tapped filter
        _filters.updateAll((key, value) => key == filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Insights"),
      ),
      body: SafeArea(
        child: BlocBuilder<InsightCubit, AllUsersInsights>(
          builder: (context, state) {
            List<Insight> insights = List.from(state.allInsights);

            // Apply filters
            if (_filters[InsightFilter.launchReady]!) {
              insights =
                  insights.where((insight) => insight.launchReady).toList();
            } else if (_filters[InsightFilter.commented]!) {
              insights =
                  insights.where((insight) => insight.comment != null).toList();
            } else if (_filters[InsightFilter.fiveStar]!) {
              insights =
                  insights.where((insight) => insight.rating == 5).toList();
            } else if (_filters[InsightFilter.flagged]!) {
              insights =
                  insights.where((insight) => insight.flag != null).toList();
            }

            // Sort the insights if a sort column is selected
            if (_sortColumnIndex != null) {
              insights.sort((a, b) {
                switch (_sortColumnIndex) {
                  case 0: // Is Launch Ready column
                    return _compareValues(a.launchReady == true ? 1 : 0,
                        b.launchReady == true ? 1 : 0);
                  case 3: // Source Functions Count
                    return _compareValues(
                        a.sourceFunctions.length, b.sourceFunctions.length);
                  case 4: // Referenced Insights Count
                    return _compareValues(a.referencedInsightIds.length,
                        b.referencedInsightIds.length);
                  default:
                    return 0;
                }
              });
            }

            double horizontalPadding = getValueForScreenType(
              context: context,
              mobile: 16.0,
              tablet: 24.0,
            );

            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          InsightFilterCard(
                            title: "Launch Ready Insights",
                            count: state.launchReadyInsightsCount,
                            total: state.insightCount,
                            isSelected: _filters[InsightFilter.launchReady]!,
                            onTap: () => _onCardTap(InsightFilter.launchReady),
                          ),
                          InsightFilterCard(
                            title: "Commented Insights",
                            count: state.commentedInsightsCount,
                            total: state.insightCount,
                            isSelected: _filters[InsightFilter.commented]!,
                            onTap: () => _onCardTap(InsightFilter.commented),
                          ),
                          InsightFilterCard(
                            title: "5 Star Insights",
                            count: state.fiveStarInsightsCount,
                            total: state.insightCount,
                            isSelected: _filters[InsightFilter.fiveStar]!,
                            onTap: () => _onCardTap(InsightFilter.fiveStar),
                          ),
                          InsightFilterCard(
                            title: "Flagged Insights",
                            count: state.flaggedInsightsCount,
                            total: state.insightCount,
                            isSelected: _filters[InsightFilter.flagged]!,
                            onTap: () => _onCardTap(InsightFilter.flagged),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: 128,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    PlatformElevatedButton(
                                      child: const Text("Export"),
                                      onPressed: () =>
                                          _showExportConfigDialog(context),
                                      material: (context, __) =>
                                          MaterialElevatedButtonData(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    PlatformTextButton(
                                      child: const Text("Import New JSON "),
                                      onPressed: () =>
                                          Navigator.pushReplacement(
                                        context,
                                        platformPageRoute(
                                          context: context,
                                          builder: (context) =>
                                              const JsonInputPage(),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              DataTable(
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _isAscending,
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: const Text(
                                      'Is Launch Ready',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      _onSort(columnIndex, ascending);
                                    },
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Insight ID',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Insight Title',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: const Text(
                                      'Source Functions Count',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      _onSort(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: const Text(
                                      'Referenced Insights Count',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      _onSort(columnIndex, ascending);
                                    },
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'User ID',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                                rows: insights
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => getInsightDataRow(
                                        entry.key,
                                        insights,
                                        context,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _isAscending = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _isAscending = true;
      }
    });
  }

  int _compareValues(int aValue, int bValue) {
    return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  }

  DataRow getInsightDataRow(
    int index,
    List<Insight> insights,
    BuildContext context,
  ) {
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Checkbox(
            value: insights[index].launchReady,
            onChanged: null,
          ),
        ),
        DataCell(
          PlatformListTile(
            title: Text(
              insights[index].insightId,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            cupertino: (_, __) => CupertinoListTileData(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsightsPage(
                    startingIndex: index,
                    insights: insights,
                  ),
                ),
              );
            },
          ),
        ),
        DataCell(Text(insights[index].title)),
        DataCell(
          Text(
            insights[index].sourceFunctions.length.toString(),
          ),
        ),
        DataCell(
          Text(
            insights[index].referencedInsightIds.length.toString(),
          ),
        ),
        DataCell(Text(insights[index].userId)),
      ],
    );
  }

  Future<void> _showExportConfigDialog(BuildContext context) async {
    final cubit = context.read<InsightCubit>();
    final config = await showPlatformDialog<ExportConfig>(
      context: context,
      builder: (BuildContext context) =>
          ExportConfigPage(config: cubit.exportConfig),
    );

    if (config != null) {
      // Update the cubit's exportConfig
      cubit.exportConfig = config;
      // Directly use the config in the toJson method
      final jsonString = jsonEncode(cubit.state.toJson(config));

      if (!context.mounted) return;
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (context) => ExportedJsonPage(jsonString: jsonString),
        ),
      );
    }
  }
}
