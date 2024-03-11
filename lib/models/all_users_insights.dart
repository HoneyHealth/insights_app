import 'models.dart';

class AllUsersInsights {
  final Map<String, List<Insight>> userInsights;

  AllUsersInsights({
    required this.userInsights,
  });

  int get userCount => userInsights.length;

  int get launchReadyInsightsCount =>
      userInsights.values.fold(0, (previousValue, insights) {
        return previousValue +
            insights.where((insight) => insight.launchReady).length;
      });

  int get commentedInsightsCount =>
      userInsights.values.fold(0, (previousValue, insights) {
        return previousValue +
            insights.where((insight) => insight.comment != null).length;
      });

  int get flaggedInsightsCount =>
      userInsights.values.fold(0, (previousValue, insights) {
        return previousValue +
            insights.where((insight) => insight.flag != null).length;
      });

  int get fiveStarInsightsCount =>
      userInsights.values.fold(0, (previousValue, insights) {
        return previousValue +
            insights.where((insight) => insight.rating == 5).length;
      });

  int get insightCount =>
      userInsights.values.fold(0, (acc, insights) => acc + insights.length);

  List<Insight> get allInsights =>
      userInsights.values.fold([], (acc, insights) => acc + insights);

  factory AllUsersInsights.fromJson(Map<String, dynamic> json) {
    Map<String, List<Insight>> userInsights = {};

    json.forEach((key, value) {
      if (value is List) {
        userInsights[key] = (value)
            .map(
              (i) => Insight.fromJson(
                {...i as Map<String, dynamic>, "user_id": key},
              ),
            )
            .toList();
      } else {
        // Handle other unexpected formats or log an error
      }
    });

    return AllUsersInsights(userInsights: userInsights);
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    // Check if launchReady export filter is on
    bool launchReadyFilter = config?.exportLaunchReadyOnly == true;

    Map<String, List<Insight>> filteredUserInsights = {};

    userInsights.forEach((userId, insights) {
      // If launchReady export filter is on, remove users with no launch-ready insights
      if (launchReadyFilter) {
        List<Insight> launchReadyInsights =
            insights.where((insight) => insight.launchReady).toList();
        if (launchReadyInsights.isNotEmpty) {
          filteredUserInsights[userId] = launchReadyInsights;
        }
      } else {
        filteredUserInsights[userId] = insights;
      }
    });

    if (config == null ||
        config.insights == CheckState.checked ||
        config.insights == CheckState.halfChecked) {
      result = filteredUserInsights
          .map((k, v) => MapEntry(k, v.map((e) => e.toJson(config)).toList()));
    }

    return result;
  }
}
