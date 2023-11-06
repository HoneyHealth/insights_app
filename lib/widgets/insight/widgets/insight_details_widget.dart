import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

class InsightDetailsWidget extends StatelessWidget {
  const InsightDetailsWidget({
    super.key,
    required this.insight,
    required this.userId,
    required TextEditingController commentController,
  }) : _commentController = commentController;

  final Insight insight;
  final String userId;
  final TextEditingController _commentController;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          PlatformListTile(
            title: Text('Launch Ready'),
            subtitle: insight.flag != null
                ? Text(
                    'This insight is flagged. Resolve the flag before launching.',
                  )
                : Text(''),
            onTap: insight.flag == null
                ? () {
                    context
                        .read<InsightCubit>()
                        .toggleLaunchReady(userId, insight);
                  }
                : null,
            trailing: PlatformSwitch(
              value: insight.launchReady,
              onChanged: insight.flag == null
                  ? (bool value) {
                      context
                          .read<InsightCubit>()
                          .toggleLaunchReady(userId, insight);
                    }
                  : null, // Disable
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    insight.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  SelectableText(
                    insight.insight,
                  ),
                  const SizedBox(height: 8.0),
                  SelectableText(
                    "Next Steps:",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SelectableText(insight.nextSteps),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Check the maximum width provided by the parent constraints
              if (constraints.maxWidth < 600) {
                // If width is less than the threshold, return the mobile layout
                return Wrap(
                  children: [
                    InsightRatingWidget(insight: insight, userId: userId),
                    FlagInsightRegion(insight: insight, userId: userId),
                  ],
                );
              } else {
                // Otherwise, return the tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InsightRatingWidget(insight: insight, userId: userId),
                    FlagInsightRegion(insight: insight, userId: userId),
                  ],
                );
              }
            },
          ),
          const SizedBox(
            height: 24,
          ),
          PlatformTextField(
            controller: _commentController,
            onChanged: (value) {
              context.read<InsightCubit>().setComment(userId, insight, value);
            },
            material: (_, __) => MaterialTextFieldData(
              decoration: const InputDecoration(
                labelText: 'Comments',
                alignLabelWithHint: true,
                hintText: 'Optional',
              ),
            ),
            cupertino: (_, __) => CupertinoTextFieldData(
              placeholder: 'Comments (Optional)',
              padding: const EdgeInsets.all(12.0),
            ),
          ),
        ],
      ),
    );
  }
}

class FlagInsightRegion extends StatelessWidget {
  const FlagInsightRegion({
    super.key,
    required this.insight,
    required this.userId,
  });

  final Insight insight;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          if (insight.flag != null)
            IntrinsicWidth(
              child: PlatformListTile(
                title: Text("Flagged for: ${insight.flag!.reason}"),
                subtitle: insight.flag!.comment != null
                    ? Text("Comment: ${insight.flag!.comment}")
                    : null,
              ),
            ),
          FlagInsightButtonWidget(
            insight: insight,
            userId: userId,
          ),
        ],
      ),
    );
  }
}

class InsightRatingWidget extends StatelessWidget {
  const InsightRatingWidget({
    super.key,
    required this.insight,
    required this.userId,
  });

  final Insight insight;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: insight.rating ?? 0,
      minRating: 0.5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star_rounded,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        context.read<InsightCubit>().setRating(userId, insight, rating);
      },
    );
  }
}

class FlagInsightButtonWidget extends StatelessWidget {
  const FlagInsightButtonWidget({
    super.key,
    required this.insight,
    required this.userId,
  });

  final Insight insight;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: insight.flag == null
          ? PlatformPopupMenu(
              cupertino: (BuildContext _, PlatformTarget __) =>
                  CupertinoPopupMenuData(
                title: const Text("Flag Insight"),
                cancelButtonData: CupertinoPopupMenuCancelButtonData(
                  child: const Text("Cancel"),
                ),
              ),
              options: [
                PopupMenuOption(
                    label: 'Inaccurate',
                    onTap: (popupMenuOption) {
                      context
                          .read<InsightCubit>()
                          .flagInsight(userId, insight, popupMenuOption.label!);
                    }),
                PopupMenuOption(
                    label: 'Irrelevant',
                    onTap: (popupMenuOption) {
                      context
                          .read<InsightCubit>()
                          .flagInsight(userId, insight, popupMenuOption.label!);
                    }),
                PopupMenuOption(
                    label: 'Other',
                    onTap: (popupMenuOption) {
                      showPlatformDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final commentController = TextEditingController();
                          return PlatformAlertDialog(
                            title: const Text("Comment"),
                            content: PlatformTextFormField(
                              autofocus: true,
                              controller: commentController,
                              maxLines: 5,
                              material: (_, __) => MaterialTextFormFieldData(
                                decoration: const InputDecoration(
                                  hintText:
                                      "Optionally enter more details on why this insight is flagged as other",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            actions: [
                              PlatformElevatedButton(
                                onPressed: () {
                                  context.read<InsightCubit>().flagInsight(
                                      userId,
                                      insight,
                                      popupMenuOption.label!,
                                      commentController.text);
                                  Navigator.pop(
                                      context); // close comment dialog
                                },
                                child: const Text("Submit"),
                              )
                            ],
                          );
                        },
                      );
                    })
              ],
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.flag_outlined),
              ),
            )
          : PlatformIconButton(
              key: const ValueKey('flag_circle_rounded'),
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<InsightCubit>().removeFlag(userId, insight);
              },
              material: (_, __) => MaterialIconButtonData(
                tooltip: "Remove Flag",
              ),
              icon: const Icon(
                Icons.flag_rounded,
                color: Colors.red,
              ),
            ),
    );
  }
}
