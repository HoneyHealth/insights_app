import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            title: const Text('Launch Ready'),
            value: insight.launchReady,
            onChanged: insight.flag == null
                ? (bool value) {
                    context
                        .read<InsightCubit>()
                        .toggleLaunchReady(userId, insight);
                  }
                : null, // Disable if flagged
            subtitle: insight.flag != null
                ? const Text(
                    'This insight is flagged. Resolve the flag before launching.')
                : const Text(''),
          ),
          Card(
            child: ListTile(
              title: SelectableText(insight.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(insight.insight),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Next Steps:",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingBar.builder(
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
                  context
                      .read<InsightCubit>()
                      .setRating(userId, insight, rating);
                },
              ),
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    if (insight.flag != null)
                      IntrinsicWidth(
                        child: ListTile(
                          title: Text("Flagged for: ${insight.flag!.reason}"),
                          subtitle: insight.flag!.comment != null
                              ? Text("Comment: ${insight.flag!.comment}")
                              : null,
                        ),
                      ),
                    MenuAnchor(
                      alignmentOffset: const Offset(-70, 0),
                      menuChildren: [
                        MenuItemButton(
                          child: const Text("Inaccurate"),
                          onPressed: () {
                            context
                                .read<InsightCubit>()
                                .flagInsight(userId, insight, "Inaccurate");
                          },
                        ),
                        MenuItemButton(
                          child: const Text("Irrelevant"),
                          onPressed: () {
                            context
                                .read<InsightCubit>()
                                .flagInsight(userId, insight, "Irrelevant");
                          },
                        ),
                        MenuItemButton(
                          child: const Text("Other"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final commentController =
                                    TextEditingController();
                                return AlertDialog(
                                  title: const Text("Comment"),
                                  content: TextFormField(
                                    controller: commentController,
                                    maxLines: 5,
                                    decoration: const InputDecoration(
                                      hintText:
                                          "Optionally enter more details on why this insight is flagged as other",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<InsightCubit>()
                                            .flagInsight(
                                                userId,
                                                insight,
                                                'Other',
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
                          },
                        ),
                      ],
                      builder: (context, controller, child) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: insight.flag == null
                            ? IconButton(
                                key: const ValueKey('flag_outlined'),
                                icon: const Icon(Icons.flag_outlined),
                                tooltip: "Flag Insight",
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                })
                            : IconButton(
                                key: const ValueKey('flag_circle_rounded'),
                                onPressed: () {
                                  context
                                      .read<InsightCubit>()
                                      .removeFlag(userId, insight);
                                },
                                tooltip: "Remove insight flag",
                                icon: const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.red,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          TextFormField(
            controller: _commentController,
            onChanged: (value) {
              context.read<InsightCubit>().setComment(userId, insight, value);
            },
            decoration: const InputDecoration(
              labelText: 'Comments',
              alignLabelWithHint: true,
              hintText: 'Optional',
            ),
          ),
        ],
      ),
    );
  }
}
