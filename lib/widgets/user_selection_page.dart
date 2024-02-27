import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insights_page.dart';

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Insights"),
      ),
      body: SafeArea(
        child: BlocBuilder<InsightCubit, AllUsersInsights>(
          builder: (context, state) {
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
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Insight ID',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Insight Title',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'User ID',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                      rows: state.allInsights
                          .asMap()
                          .entries
                          .map(
                            (entry) => getInsightDataRow(
                              entry.key,
                              state.allInsights,
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
        DataCell(Text(insights[index].userId)),
      ],
    );
  }
}
