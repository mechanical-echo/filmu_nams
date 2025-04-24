import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              scheduleData == null ||
                      (scheduleData!.isNotEmpty && availableDates.isNotEmpty)
                  ? "Nopirkt biļeti"
                  : "Nav pieejama saraksta",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 40,
              ),
            )
          else if (scheduleData!.isNotEmpty && availableDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Izvēlieties datumu un laiku',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DatePickerInput(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 24,
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: timeList,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedId = value;
                                      });
                                    },
                                    value: selectedId,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF2A2A2A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (selectedId != null)
                    HallSeats(
                      scheduleId: selectedId!,
                      hallId: getHall(),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
