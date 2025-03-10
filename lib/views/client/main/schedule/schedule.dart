import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_list.dart';
import 'package:filmu_nams/views/client/main/schedule/schedule_list/schedule_list.dart';
import 'package:flutter/material.dart';

class ScheduleAndMovies extends StatelessWidget {
  const ScheduleAndMovies({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 170.0, bottom: 105),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StylizedTabs(
            tabs: [
              StylizedTabPage(
                title: StylizedTabTitle.text('Saraksts'),
                child: ScheduleWidget(),
              ),
              StylizedTabPage(
                title: StylizedTabTitle.text('Visas filmas'),
                child: MovieList(),
              )
            ],
          ),
        ],
      ),
    );
  }
}
