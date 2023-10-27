import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/widgets/insight/insight_widget.dart';
import 'package:insights_app/main.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insights_cubit.dart';
import 'models.dart';

class UserInsightsPage extends StatefulWidget {
  final String userId;

  const UserInsightsPage({required this.userId, super.key});

  @override
  State<UserInsightsPage> createState() => _UserInsightsPageState();
}

class _UserInsightsPageState extends State<UserInsightsPage> {
  int currentInsightIndex = 0;

  String getUserProgressText() {
    final cubit = context.read<InsightCubit>();
    final allUsers = cubit.state.userInsights.keys.toList();
    final currentUserIndex = allUsers.indexOf(widget.userId);

    return "${currentUserIndex + 1}/${allUsers.length} users";
  }

  String getInsightProgressText() {
    final insights = context
            .read<InsightCubit>()
            .state
            .userInsights[widget.userId]
            ?.insights ??
        [];
    return "${currentInsightIndex + 1}/${insights.length} insights";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights for ${widget.userId}"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          var insights = state.userInsights[widget.userId]?.insights ?? [];

          if (insights.isEmpty) return const Text("No insights available.");

          return Column(
            children: [
              Expanded(
                child:
                    InsightWidget(widget.userId, insights[currentInsightIndex]),
              ),
              BottomAppBar(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: min(
                          MediaQuery.of(context).size.width - 32,
                          getValueForScreenType(
                            context: context,
                            mobile: 600 - 32,
                            tablet: 900 - 32,
                            desktop: 1200 - 32,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentInsightIndex > 0)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      currentInsightIndex--;
                                    });
                                  },
                                  child: const Text("Previous"),
                                )
                              else
                                const SizedBox(
                                  width: 108,
                                ),
                              getValueForScreenType(
                                context: context,
                                mobile: Column(
                                  children: [
                                    Text(
                                      getUserProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      getInsightProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                tablet: Row(children: [
                                  Text(getUserProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(getInsightProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (currentInsightIndex <
                                      insights.length - 1) {
                                    setState(() {
                                      currentInsightIndex++;
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InsightSummaryPage(
                                                userId: widget.userId),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                    currentInsightIndex < insights.length - 1
                                        ? "Next"
                                        : "Summary"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
