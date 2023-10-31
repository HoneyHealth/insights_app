import 'package:flutter/material.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insight_widget.mobile.dart';
import 'insight_widget.desktop.dart';

class InsightWidget extends StatelessWidget {
  final String userId;
  final Insight insight;

  const InsightWidget(this.userId, this.insight, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => InsightMobileWidget(userId, insight),
      desktop: (_) => InsightDesktopWidget(userId, insight),
    );
  }
}
