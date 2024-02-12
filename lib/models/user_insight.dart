import 'models.dart';

class UserInsight {
  final List<Insight> insights;

  UserInsight({required this.insights});

  factory UserInsight.fromJson(Map<String, dynamic> json) {
    List<Insight> insightsList;

    insightsList = (json['insights'] as List)
        .map((i) => Insight.fromJson(i as Map<String, dynamic>))
        .toList();

    return UserInsight(
      insights: insightsList,
    );
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    List<Insight> filteredInsights;
    if (config?.exportLaunchReadyOnly == true) {
      filteredInsights = insights.where((i) => i.launchReady).toList();
    } else {
      filteredInsights = insights;
    }

    if (config == null ||
        config.userInsight == CheckState.checked ||
        config.userInsight == CheckState.halfChecked) {
      result['insights'] =
          filteredInsights.map((e) => e.toJson(config)).toList();
    }

    return result;
  }
}
