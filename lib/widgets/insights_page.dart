import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/insight/insight_widget.dart';
import 'package:insights_app/widgets/overall_insight_summary_page.dart';
import 'package:responsive_builder/responsive_builder.dart';

class InsightsPage extends StatefulWidget {
  final List<Insight> insights;
  final int startingIndex;

  const InsightsPage({
    required this.insights,
    this.startingIndex = 0,
    super.key,
  });

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late int currentInsightIndex;

  @override
  void initState() {
    super.initState();
    currentInsightIndex = widget.startingIndex;
  }

  String getInsightProgressText() {
    return "${currentInsightIndex + 1}/${widget.insights.length} insights";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) return const Text("No insights available.");

    return BlocBuilder<InsightCubit, AllUsersInsights>(
      builder: (context, state) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Insights"),
        ),
        iosContentPadding: true,
        body: Column(
          children: [
            Expanded(
              child: InsightWidget(
                widget.insights[currentInsightIndex].userId,
                widget.insights[currentInsightIndex],
              ),
            ),
            PlatformWidget(
              material: (_, __) => BottomAppBar(
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
                              PlatformElevatedButton(
                                onPressed: currentInsightIndex > 0
                                    ? () {
                                        setState(() {
                                          currentInsightIndex--;
                                        });
                                      }
                                    : null,
                                child: const Text("Previous"),
                              ),
                              Text(
                                getInsightProgressText(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PlatformElevatedButton(
                                onPressed: () {
                                  if (currentInsightIndex <
                                      widget.insights.length - 1) {
                                    setState(() {
                                      currentInsightIndex++;
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      platformPageRoute(
                                        context: context,
                                        builder: (context) =>
                                            const OverallInsightSummaryPage(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(currentInsightIndex <
                                        widget.insights.length - 1
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
              cupertino: (_, __) => Row(
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
                            PlatformTextButton(
                              onPressed: currentInsightIndex > 0
                                  ? () {
                                      setState(() {
                                        currentInsightIndex--;
                                      });
                                    }
                                  : null,
                              child: const Text("Previous"),
                            ),
                            Text(
                              getInsightProgressText(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PlatformTextButton(
                              onPressed: () {
                                if (currentInsightIndex <
                                    widget.insights.length - 1) {
                                  setState(() {
                                    currentInsightIndex++;
                                  });
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (context) =>
                                          const OverallInsightSummaryPage(),
                                    ),
                                  );
                                }
                              },
                              child: Text(currentInsightIndex <
                                      widget.insights.length - 1
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
            )
          ],
        ),
      ),
    );
  }
}
