import 'models.dart';

class UserInsights {
  final List<Insight> insights;

  UserInsights({required this.insights});

  factory UserInsights.fromJson(List<Map<String, dynamic>> jsonList) {
    List<Insight> insightsList;

    insightsList = jsonList.map((i) => Insight.fromJson(i)).toList();

    return UserInsights(
      insights: insightsList,
    );
  }

  List<Map<String, dynamic>> toJson([ExportConfig? config]) {
    List<Map<String, dynamic>> result = [];

    List<Insight> filteredInsights;
    if (config?.exportLaunchReadyOnly == true) {
      filteredInsights = insights.where((i) => i.launchReady).toList();
    } else {
      filteredInsights = insights;
    }

    if (config == null ||
        config.userInsight == CheckState.checked ||
        config.userInsight == CheckState.halfChecked) {
      result = filteredInsights.map((e) => e.toJson(config)).toList();
    }

    return result;
  }
}
