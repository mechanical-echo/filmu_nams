import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({super.key});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  List<ScheduleModel>? scheduleData;
  bool isLoading = true;

  Future<void> fetchSchedule() async {
    final currentDate = DateTime(2025, 3, 2);

    try {
      final response = await MovieController().getSchedule(currentDate);
      setState(() {
        scheduleData = response;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching schedule: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StylizedTabs(
          upsideDown: true,
          fontSize: 20.5,
          tabs: [
            StylizedTabPage(
              title: StylizedTabTitle.text("Šodien"),
              child: scheduleList(context),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Rīt"),
              child: scheduleList(context),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Pārīt"),
              child: scheduleList(context),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.icon(Icons.calendar_month),
              child: scheduleList(context),
            ),
          ],
        ),
      ],
    );
  }

  SizedBox scheduleList(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 325,
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 100)
          : GridView.count(
              padding: const EdgeInsets.only(top: 10, bottom: 70),
              crossAxisCount: 1,
              childAspectRatio: 1.5,
              mainAxisSpacing: 10,
              children: List.generate(
                scheduleData!.length,
                (index) => ScheduleMovieItem(
                  data: scheduleData![index],
                ),
              ),
            ),
    );
  }
}

class ScheduleMovieItem extends StatelessWidget {
  const ScheduleMovieItem({
    super.key,
    required this.data,
  });

  final ScheduleModel data;

  @override
  Widget build(BuildContext context) {
    return MovieCard(
      data: data.movie,
    );
  }
}
