import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/custom_expansion_tile.dart';
import 'package:insights_app/widgets/export_config_page.dart';
import 'package:insights_app/widgets/exported_json_page.dart';

class OverallInsightSummaryPage extends StatelessWidget {
  const OverallInsightSummaryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Overall Insights Summary"),
        trailingActions: [
          PlatformWidget(
            cupertino: (_, __) => PlatformIconButton(
              onPressed: () => _showExportConfigDialog(context),
              icon: Icon(PlatformIcons(context).cloudDownloadSolid),
            ),
          )
        ],
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.userInsights.keys.length,
            itemBuilder: (context, index) {
              final userId = state.userInsights.keys.elementAt(index);
              final insights = state.userInsights[userId] ?? [];
              return CustomExpansionTile(
                title: Text("User: $userId"),
                children: insights.map((insight) {
                  return PlatformListTile(
                    title: Text(insight.title),
                    trailing: buildTrailingWidgets(insight, context),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showExportConfigDialog(context),
          tooltip: "Export to JSON",
          child: Icon(PlatformIcons(context).cloudDownload),
        ),
      ),
    );
  }

  Widget buildTrailingWidgets(Insight insight, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(insight.rating != null
            ? insight.rating!.toStringAsFixed(
                insight.rating!.truncateToDouble() == insight.rating! ? 0 : 1)
            : 'Not Rated'),
        const SizedBox(width: 10),
        if (insight.launchReady)
          const Icon((Icons.launch), color: Colors.green),
        if (insight.flag != null)
          const Icon(Icons.flag_rounded, color: Colors.red),
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
