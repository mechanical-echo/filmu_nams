import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/date_picker/date_picker_input.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  Future<void> fetchScheduleDataForMovie() async {
    final response =
        await MovieController().getScheduleByMovie(widget.movieData);
    setState(() {
      scheduleData = response;
      isLoading = false;

      if (response.isEmpty) {
        return;
      }

      for (var date in scheduleData!) {
        availableDates.add(date.time.toDate());
      }
      selectedDate = availableDates[0];
      getDropdownList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchScheduleDataForMovie();
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
      selectedId = list[0].value;
    });
  }

  DateTime getDateByScheduleId(String? id) {
    return scheduleData!
        .firstWhere((sch) => sch.id == id, orElse: () => scheduleData![0])
        .time
        .toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
          child: Divider(
            color: smokeyWhite.withAlpha(20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
              scheduleData == null || scheduleData!.isNotEmpty
                  ? "Nopirkt biļeti"
                  : "Nav pieejama saraksta",
              style: header2),
        ),
        isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 100,
                ),
              )
            : scheduleData!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DatePickerInput(
                            availableDates: availableDates,
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
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: classicDecoration,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButton(
                              iconEnabledColor: Colors.white,
                              underline: Container(),
                              style: bodyMedium,
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
                      ],
                    ),
                  )
                : Container(),
      ],
    );
  }
}
