import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/models/models.dart';
import 'package:insights_app/widgets/insight/insight_widget.dart';
import 'package:insights_app/widgets/insight_summary_page.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../insights_cubit.dart';

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
    final insights =
        context.read<InsightCubit>().state.userInsights[widget.userId] ?? [];
    return "${currentInsightIndex + 1}/${insights.length} insights";
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Insights for ${widget.userId}"),
      ),
      iosContentPadding: true,
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          var insights = state.userInsights[widget.userId] ?? [];

          if (insights.isEmpty) return const Text("No insights available.");

          return Column(
            children: [
              Expanded(
                child:
                    InsightWidget(widget.userId, insights[currentInsightIndex]),
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
                                getValueForScreenType(
                                  context: context,
                                  mobile: Column(
                                    children: [
                                      Text(
                                        getUserProgressText(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        getInsightProgressText(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  tablet: Row(children: [
                                    Text(
                                      getUserProgressText(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      getInsightProgressText(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),
                                ),
                                PlatformElevatedButton(
                                  onPressed: () {
                                    if (currentInsightIndex <
                                        insights.length - 1) {
                                      setState(() {
                                        currentInsightIndex++;
                                      });
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        platformPageRoute(
                                          context: context,
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
                              getValueForScreenType(
                                context: context,
                                mobile: Column(
                                  children: [
                                    Text(
                                      getUserProgressText(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      getInsightProgressText(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                tablet: Row(children: [
                                  Text(
                                    getUserProgressText(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    getInsightProgressText(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                              ),
                              PlatformTextButton(
                                onPressed: () {
                                  if (currentInsightIndex <
                                      insights.length - 1) {
                                    setState(() {
                                      currentInsightIndex++;
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      platformPageRoute(
                                        context: context,
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
              )
            ],
          );
        },
      ),
    );
  }
}
