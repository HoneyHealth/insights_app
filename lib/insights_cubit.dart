import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/models.dart';

class InsightCubit extends Cubit<AllUsersInsights> {
  InsightCubit(AllUsersInsights initialState) : super(initialState);
  ExportConfig exportConfig = ExportConfig();

  void updateInsights(AllUsersInsights insights) {
    emit(insights);
  }

  void setRating(String userId, Insight insight, double rating) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.rating = rating;

    emit(insightsCopy);
  }

  void setComment(String userId, Insight insight, String comment) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.comment = comment;

    emit(insightsCopy);
  }

  void toggleLaunchReady(String userId, Insight insight) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.launchReady = !targetInsight.launchReady; // Toggle the value

    emit(insightsCopy);
  }

  void flagInsight(String userId, Insight insight, String reason,
      [String? comment]) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.flag = Flag(reason: reason, comment: comment);

    // Disabling launch ready if the insight is flagged
    targetInsight.launchReady = false;

    emit(insightsCopy);
  }

  void removeFlag(String userId, Insight insight) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.flag = null;

    emit(insightsCopy);
  }
}
