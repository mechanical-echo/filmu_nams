import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:filmu_nams/assets/widgets/date_picker/date_picker_input.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/hall_seats.dart';

class TicketBuyingForm extends StatefulWidget {
  const TicketBuyingForm({
    super.key,
    required this.movieData,
  });

  final MovieModel movieData;

  @override
  State<TicketBuyingForm> createState() => _TicketBuyingFormState();
}

class _TicketBuyingFormState extends State<TicketBuyingForm> {
  List<DropdownMenuItem<String>> timeList = [];
  List<ScheduleModel>? scheduleData;
  List<DateTime> availableDates = [];

  bool isLoading = true;
  DateTime? selectedDate;
  String? selectedId;

  Style get style => Style.of(context);

  @override
  void initState() {
    super.initState();
    fetchScheduleDataForMovie();
  }

  Future<void> fetchScheduleDataForMovie() async {
    final response =
        await MovieController().getScheduleByMovie(widget.movieData);
    setState(() {
      scheduleData = response;
      isLoading = false;

      if (response.isEmpty) return;

      for (var date in scheduleData!) {
        if (date.time.toDate().isAfter(DateTime.now())) {
          availableDates.add(date.time.toDate());
        }
      }

      if (availableDates.isEmpty) return;

      selectedDate = availableDates[0];
      getDropdownList();
    });
  }

  bool isSameDate(dateA, dateB) =>
      dateA.day == dateB.day &&
      dateA.month == dateB.month &&
      dateA.year == dateB.year;

  void getDropdownList() {
    List<DropdownMenuItem<String>> list = [];
    for (var schedule in scheduleData!) {
      DateTime date = schedule.time.toDate();
      if (!isSameDate(date, selectedDate)) continue;

      list.add(DropdownMenuItem(
        value: schedule.id,
        child: Text(DateFormat('HH:mm', 'lv').format(date)),
      ));
    }
    setState(() {
      timeList = list;
      selectedId = list.isNotEmpty ? list[0].value : null;
    });
  }

  DateTime getDateByScheduleId(String? id) {
    return scheduleData!
        .firstWhere((sch) => sch.id == id, orElse: () => scheduleData![0])
        .time
        .toDate();
  }

  int getHall() {
    return scheduleData!
        .firstWhere((sch) => sch.id == selectedId,
            orElse: () => scheduleData![0])
        .hall;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: style.roundCardDecoration.copyWith(
        color: style.contrast.withAlpha(50),
      ),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                scheduleData == null ||
                        (scheduleData!.isNotEmpty && availableDates.isNotEmpty)
                    ? "Nopirkt biļeti"
                    : "Nav pieejama saraksta",
                style: style.displaySmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: style.contrast,
                size: 40,
              ),
            )
          else if (scheduleData!.isNotEmpty && availableDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: style.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Izvēlieties datumu un laiku',
                          style: style.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DatePickerInput(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                availableDates: availableDates,
                                sharp: true,
                                height: 50,
                                onDateChanged: (date) {
                                  setState(() {
                                    selectedDate = date;
                                    getDropdownList();
                                  });
                                },
                                initialValue: selectedDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: style.cardDecoration,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: style.contrast.withAlpha(100),
                                      size: 24,
                                    ),
                                    style: style.bodyMedium,
                                    items: timeList,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedId = value;
                                      });
                                    },
                                    value: selectedId,
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedId != null)
                    HallSeats(
                      scheduleId: selectedId!,
                      hallId: getHall(),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
