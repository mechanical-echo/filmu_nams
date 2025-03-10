import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/assets/widgets/date_picker/date_picker_input.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/foldable_description.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MovieView extends StatelessWidget {
  const MovieView({
    super.key,
    required this.data,
  });

  final MovieModel data;

  static void show(BuildContext context, MovieModel data) {
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: Navigator.of(context),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      transitionAnimationController: animationController,
      builder: (context) => MovieView(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: red001,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      width: width,
      height: height * 0.82,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: width,
            height: 250,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(190),
                        blurRadius: 25,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: data.heroUrl,
                    placeholder: (context, url) =>
                        LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 35),
              child: Column(
                children: [
                  title(),
                  FoldableDescription(data: data),
                  TicketBuyingForm(movieData: data)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTitle(String s) => s.replaceFirst(':', ':\n');

  Container title() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: bottomBorder,
        boxShadow: cardShadow,
        color: red002,
      ),
      child: Text(
        formatTitle(data.title),
        style: bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

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
      for (var date in scheduleData!) {
        availableDates.add(date.time.toDate());
      }
      selectedDate = availableDates[0];
    });
    getDropdownList();
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

  bool isSameDateTime(dateA, dateB) =>
      dateA.day == dateB.day &&
      dateA.month == dateB.month &&
      dateA.year == dateB.year &&
      dateA.hour == dateB.hour &&
      dateA.minute == dateB.minute;

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

  List<DropdownMenuItem<String>> timeList = [];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 100,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 15,
            ),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DatePickerInput(
                  availableDates: availableDates,
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                      getDropdownList();
                    });
                  },
                  initialValue: selectedDate,
                ),
                DropdownButton(
                  style: bodyMedium,
                  items: timeList,
                  onChanged: (value) {
                    setState(() {
                      selectedId = value;
                    });
                  },
                  value: selectedId,
                ),
              ],
            ),
          );
  }

  DateTime getDateByScheduleId(String? id) {
    return scheduleData!
        .firstWhere((sch) => sch.id == id, orElse: () => scheduleData![0])
        .time
        .toDate();
  }
}
