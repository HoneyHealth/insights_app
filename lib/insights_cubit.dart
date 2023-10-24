import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/models.dart';

class InsightCubit extends Cubit<AllUsersInsights> {
  InsightCubit(AllUsersInsights initialState) : super(initialState);

  void setRating(String userId, Insight insight, int rating) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.rating = rating;

    emit(insightsCopy);
  }

  void setFeedback(String userId, Insight insight, String feedback) {
    final insightsCopy =
        AllUsersInsights(userInsights: {...state.userInsights});

    final userInsights = insightsCopy.userInsights[userId];
    final targetInsight =
        userInsights!.insights.firstWhere((i) => i == insight);
    targetInsight.feedback = feedback;

    emit(insightsCopy);
  }
}
