import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';

import 'insights_page.dart';

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    [] + [];
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Select a User"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView(
            children: [
              ...state.userInsights.keys.map(
                (userId) {
                  return PlatformListTile(
                    title: Text(
                      userId,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserInsightsPage(userId: userId),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 132,
              ),
            ],
          );
        },
      ),
    );
  }
}
