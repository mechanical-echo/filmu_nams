import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/schedule_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSchedule extends StatefulWidget {
  const ManageSchedule({
    super.key,
    required this.action,
  });

  final Function(String, String) action;

  @override
  State<ManageSchedule> createState() => _ManageScheduleState();
}

class _ManageScheduleState extends State<ManageSchedule> {
  List<ScheduleModel> scheduleItems = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchScheduleFromFirebase();
  }

  Future<void> fetchScheduleFromFirebase() async {
    try {
      final response = await MovieController().getAllSchedule();
      setState(() {
        scheduleItems = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching schedule items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ScheduleModel> getFilteredSchedule() {
    if (scheduleItems.isEmpty) return [];

    return scheduleItems.where((item) {
      final itemDate = item.time.toDate();
      return itemDate.year == selectedDate.year &&
          itemDate.month == selectedDate.month &&
          itemDate.day == selectedDate.day;
    }).toList();
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = getFilteredSchedule();

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        dateSelector(),
        ManageScreen(
          count: filteredItems.length,
          isLoading: isLoading,
          itemGenerator: (index) => generateCard(filteredItems)(index),
          title:
              "Saraksts - ${DateFormat('d MMMM y', 'lv').format(selectedDate)}",
        ),
        IntrinsicWidth(
          child: StylizedButton(
            action: () => widget.action("add_schedule", ""),
            title: "Pievienot sarakstu",
            icon: Icons.add_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget dateSelector() {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: classicDecorationSharp,
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: smokeyWhite),
              onPressed: () => onDateSelected(
                selectedDate.subtract(const Duration(days: 1)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: classicDecorationWhiteSharper,
              child: Text(
                DateFormat('EEEE, d MMMM y', 'lv').format(selectedDate),
                style: bodyMediumRed,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: smokeyWhite),
              onPressed: () => onDateSelected(
                selectedDate.add(const Duration(days: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Function(int) generateCard(List<ScheduleModel> items) {
    return (index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: classicDecorationSharp,
          child: ScheduleCard(
            data: items[index],
            onEdit: (scheduleId) {
              widget.action("edit_schedule", scheduleId);
            },
          ),
        );
  }
}
