import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insights_page.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  int? _sortColumnIndex; // Start with no column sorted
  bool _isAscending = true;

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

            // Sort the insights if a sort column is selected
            if (_sortColumnIndex != null) {
              insights.sort((a, b) {
                int aValue = a.sourceFunctions.length;
                int bValue = b.sourceFunctions.length;
                return _isAscending
                    ? aValue.compareTo(bValue)
                    : bValue.compareTo(aValue);
              });
            }

            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: BoxConstraints(
                  maxWidth: getValueForScreenType(
                    context: context,
                    mobile: 600,
                    tablet: 900,
                    desktop: 1200,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _isAscending,
                      columns: <DataColumn>[
                        const DataColumn(
                          label: Text(
                            'Insight ID',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            'Insight Title',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: const Text(
                            'Source Functions Count',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              if (_sortColumnIndex == columnIndex) {
                                _isAscending = ascending;
                              } else {
                                _sortColumnIndex = columnIndex;
                                _isAscending = true;
                              }
                            });
                          },
                        ),
                        const DataColumn(
                          label: Text(
                            'User ID',
                            style: TextStyle(fontStyle: FontStyle.italic),
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DataRow getInsightDataRow(
    int index,
    List<Insight> insights,
    BuildContext context,
  ) {
    return DataRow(
      cells: <DataCell>[
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
        DataCell(Text(insights[index].userId)),
      ],
    );
  }
}
