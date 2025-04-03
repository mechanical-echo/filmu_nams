import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_list.dart';
import 'package:filmu_nams/views/client/main/schedule/schedule_list/schedule_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleAndMovies extends StatelessWidget {
  const ScheduleAndMovies({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saraksts',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atrastie filmu seansi un piedāvājumi',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
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
