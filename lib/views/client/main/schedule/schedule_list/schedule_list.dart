import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/assets/widgets/date_picker/date_picker.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_card.dart';
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
  DateTime? datePickerSelectedDate;
  List<DateTime> availableDates = [];

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _scheduleFetchSubscription;

  @override
  void dispose() {
    _scheduleFetchSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchAllSchedule() async {
    _scheduleFetchSubscription =
        _firestore.collection('schedule').snapshots().listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        setAvailableDates(items);
        // isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to carousel changes: $e');
      setState(() {
        // isLoading = false;
      });
    });
  }

  void setAvailableDates(List<ScheduleModel> scheduleData) {
    setState(() {
      for (ScheduleModel schedule in scheduleData) {
        if (schedule.time.toDate().isAfter(DateTime.now())) {
          availableDates.add(schedule.time.toDate());
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          StylizedTabs(
            upsideDown: true,
            fontSize: 19.5,
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
                child: ScheduleDateView(
                  date: datePickerSelectedDate,
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
            top: isDatePickerOpen ? 50 : -400,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Cubic(1, 0, 0, 1),
              opacity: isDatePickerOpen ? 1.0 : 0.0,
              child: DatePicker(
                onDateSelected: onDateSelected,
                availableDates: availableDates,
              ),
            ),
          ),
        ],
      ),
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
      final response = await MovieController().getScheduleByDate(currentDate);
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
    final theme = Style.of(context);

    return isLoading
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
                  (index) => MovieCard(
                    data: scheduleData![index].movie,
                    time: scheduleData![index].time.toDate(),
                    hall: scheduleData![index].hall,
                  ),
                ),
              )
            : Center(
                child: Text(
                  "Saraksts izvēlētājā dienā ir tūkšs",
                  style: theme.bodySmall,
                ),
              );
  }
}
