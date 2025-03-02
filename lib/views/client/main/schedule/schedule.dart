import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list.dart';
import 'package:filmu_nams/views/client/main/schedule/schedule_list.dart';
import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 170.0, bottom: 105),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StylizedTabs(
              tabs: [
                StylizedTabPage(
                  title: 'Saraksts',
                  child: ScheduleList(),
                ),
                StylizedTabPage(
                  title: 'Visas filmas',
                  child: MovieList(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
