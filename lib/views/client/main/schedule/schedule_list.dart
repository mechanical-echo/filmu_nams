import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/client/main/schedule/date_picker.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  DateTime today() => DateTime.now();
  DateTime tomorrow() => today().add(const Duration(days: 1));
  DateTime dayAfterTomorrow() => today().add(const Duration(days: 2));

  bool isDatePickerOpen = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StylizedTabs(
          upsideDown: true,
          fontSize: 20.5,
          tabs: [
            StylizedTabPage(
              title: StylizedTabTitle.text("Šodien"),
              child: ScheduleDateView(date: today()),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Rīt"),
              child: ScheduleDateView(date: tomorrow()),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Pārīt"),
              child: ScheduleDateView(date: dayAfterTomorrow()),
            ),
            StylizedTabPage(
              title: StylizedTabTitle.icon(Icons.calendar_month),
              child: ScheduleDateView(
                date: DateTime.now().add(const Duration(days: 3)),
              ),
              onTap: () {
                setState(() {
                  isDatePickerOpen = !isDatePickerOpen;
                });
              },
            ),
          ],
        ),
        if (isDatePickerOpen)
          Positioned(
            right: 50,
            top: 50,
            child: DatePicker(),
          ),
      ],
    );
  }
}

class ScheduleDateView extends StatefulWidget {
  const ScheduleDateView({super.key, required this.date});

  final DateTime date;

  @override
  State<ScheduleDateView> createState() => _ScheduleDateViewState();
}

class _ScheduleDateViewState extends State<ScheduleDateView> {
  List<ScheduleModel>? scheduleData;
  bool isLoading = true;

  Future<void> fetchSchedule() async {
    final currentDate = widget.date;

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
    return SizedBox(
      height: MediaQuery.of(context).size.height - 425,
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 100)
          : scheduleData!.length == 1
              ? GridView.count(
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
                )
              : Center(
                  child: Text(
                    "Saraksts izvēlētājā dienā ir tūkšs",
                    style: bodyMedium,
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
