import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_list.dart';
import 'package:filmu_nams/views/client/main/schedule/schedule_list/schedule_list.dart';
import 'package:flutter/material.dart';

class ScheduleAndMovies extends StatelessWidget {
  const ScheduleAndMovies({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Saraksts 🗓️',
                style: theme.displaySmall,
              ),
              Text(
                'Filmu seansi un piedāvājumi',
                style: theme.titleSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: StylizedTabs(
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
        ),
      ],
    );
  }
}
