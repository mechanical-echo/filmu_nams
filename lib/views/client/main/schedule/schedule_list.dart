import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/client/main/schedule/date_picker.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime? datePickerSelectedDate;

  void onDateSelected(DateTime date) {
    setState(() {
      datePickerSelectedDate = date;
      isDatePickerOpen = false;
    });
  }

  void closeDatePicker() {
    setState(() {
      isDatePickerOpen = false;
      datePickerSelectedDate = null;
    });
  }

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
              onTap: closeDatePicker,
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Rīt"),
              child: ScheduleDateView(date: tomorrow()),
              onTap: closeDatePicker,
            ),
            StylizedTabPage(
              title: StylizedTabTitle.text("Pārīt"),
              child: ScheduleDateView(date: dayAfterTomorrow()),
              onTap: closeDatePicker,
            ),
            StylizedTabPage(
              title: StylizedTabTitle.icon(Icons.calendar_month),
              child: Column(
                children: [
                  if (datePickerSelectedDate != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: red002,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        DateFormat(DateFormat.ABBR_MONTH_DAY, 'lv')
                            .format(datePickerSelectedDate!),
                        style: bodyLarge,
                      ),
                    ),
                  ScheduleDateView(
                    date: datePickerSelectedDate,
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  isDatePickerOpen = true;
                });
              },
            ),
          ],
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Cubic(1, 0, 0, 1),
          right: 50,
          top: isDatePickerOpen ? 50 : -400,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Cubic(1, 0, 0, 1),
            opacity: isDatePickerOpen ? 1.0 : 0.0,
            child: DatePicker(onDateSelected: onDateSelected),
          ),
        ),
      ],
    );
  }
}

class ScheduleDateView extends StatefulWidget {
  const ScheduleDateView({super.key, required this.date});

  final DateTime? date;

  @override
  State<ScheduleDateView> createState() => _ScheduleDateViewState();
}

class _ScheduleDateViewState extends State<ScheduleDateView> {
  List<ScheduleModel>? scheduleData;
  bool isLoading = true;

  Future<void> fetchSchedule() async {
    final currentDate = widget.date;

    if (currentDate == null) {
      return;
    }

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
  void didUpdateWidget(ScheduleDateView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      setState(() {
        isLoading = true;
        scheduleData = null;
      });
      fetchSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 425,
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 100)
          : scheduleData != null && scheduleData!.isNotEmpty
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
