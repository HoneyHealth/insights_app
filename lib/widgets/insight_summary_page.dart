import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/user_insights_page.dart';
import 'package:insights_app/widgets/overall_insight_summary_page.dart';

class InsightSummaryPage extends StatelessWidget {
  final String userId;

  const InsightSummaryPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Summary for $userId"),
        trailingActions: <Widget>[
          PlatformWidget(
            cupertino: (_, __) => PlatformIconButton(
              icon: Icon(Icons.adaptive.arrow_forward_rounded),
              onPressed: () {
                // Navigate to the next user's insights or go back to user selection if it's the last user
                final cubit = context.read<InsightCubit>();
                final allUsers = cubit.state.userInsights.keys.toList();
                final currentUserIndex = allUsers.indexOf(userId);

                if (currentUserIndex < allUsers.length - 1) {
                  final nextUser = allUsers[currentUserIndex + 1];
                  Navigator.pushReplacement(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => UserInsightsPage(userId: nextUser),
                    ),
                  );
                } else {
                  // If it's the last user, navigate to overall summary
                  Navigator.pushReplacement(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => const OverallInsightSummaryPage(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          final insights = state.userInsights[userId]?.insights ?? [];

          return ListView.builder(
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return PlatformListTile(
                title: Text(insight.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(insight.rating != null
                        ? insight.rating!.toStringAsFixed(
                            insight.rating!.truncateToDouble() ==
                                    insight.rating!
                                ? 0
                                : 1)
                        : 'Not Rated'),
                    const SizedBox(width: 10),
                    if (insight.launchReady)
                      const Icon(Icons.launch, color: Colors.green),
                    if (insight.flag != null)
                      const Icon(
                        Icons.flag_rounded,
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the next user's insights or go back to user selection if it's the last user
            final cubit = context.read<InsightCubit>();
            final allUsers = cubit.state.userInsights.keys.toList();
            final currentUserIndex = allUsers.indexOf(userId);

            if (currentUserIndex < allUsers.length - 1) {
              final nextUser = allUsers[currentUserIndex + 1];
              Navigator.pushReplacement(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => UserInsightsPage(userId: nextUser),
                ),
              );
            } else {
              // If it's the last user, navigate to overall summary
              Navigator.pushReplacement(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const OverallInsightSummaryPage(),
                ),
              );
            }
          },
          child: Icon(Icons.adaptive.arrow_forward_rounded),
        ),
      ),
    );
  }
}
