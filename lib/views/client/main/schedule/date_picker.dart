import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    });
  }

  void nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthDays = [
      31,
      selectedDate.year % 4 == 0 ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];

    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayPrevMonth = DateTime(selectedDate.year, selectedDate.month, 0);

    final daysFromPrevMonth = firstDay.weekday - 1;

    final currentMonthDays = monthDays[selectedDate.month - 1];
    final totalDays = daysFromPrevMonth + currentMonthDays;
    final daysFromNextMonth = (7 - (totalDays % 7)) % 7;

    return Container(
      decoration: BoxDecoration(
        color: red001,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 7,
            offset: const Offset(0, 7),
          )
        ],
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 5),
        ),
      ),
      height: 350,
      width: 330,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          header(),
          weekDays(),
          month(
            daysFromPrevMonth,
            lastDayPrevMonth,
            currentMonthDays,
            daysFromNextMonth,
          ),
        ],
      ),
    );
  }

  Stack header() {
    return Stack(
      children: [
        Positioned(
          left: 10,
          top: -10,
          child: IconButton(
            onPressed: previousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: -10,
          child: IconButton(
            onPressed: nextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        Center(
          child: Text(
            "${DateFormat(DateFormat.YEAR).format(selectedDate)} ${capitalize(DateFormat(DateFormat.STANDALONE_MONTH, 'lv').format(selectedDate))}",
            style: bodyLarge,
          ),
        ),
      ],
    );
  }

  Container month(
    int daysFromPrevMonth,
    DateTime lastDayPrevMonth,
    int currentMonthDays,
    int daysFromNextMonth,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 13, right: 10),
      height: 265,
      width: 375,
      decoration: BoxDecoration(
        color: red002,
        borderRadius: BorderRadius.circular(7),
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(5),
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [
          ...List.generate(
            daysFromPrevMonth,
            (index) => DatePickerDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                lastDayPrevMonth.day - daysFromPrevMonth + index + 1,
              ),
              disabled: true,
              currentMonth: false,
            ),
          ),
          ...List.generate(
            currentMonthDays,
            (index) => DatePickerDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month,
                index + 1,
              ),
            ),
          ),
          ...List.generate(
            daysFromNextMonth,
            (index) => DatePickerDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                index + 1,
              ),
              disabled: true,
              currentMonth: false,
            ),
          ),
        ],
      ),
    );
  }

  Container weekDays() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 295,
      height: 20,
      child: GridView.count(
        crossAxisCount: 7,
        padding: const EdgeInsets.all(0),
        mainAxisSpacing: 5,
        crossAxisSpacing: 2,
        childAspectRatio: 2,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: red002.withAlpha(200),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
              ),
            ),
            child: Center(child: Text("Pr", style: bodyMedium)),
          ),
          Container(
            color: red002.withAlpha(200),
            child: Center(child: Text("Ot", style: bodyMedium)),
          ),
          Container(
            color: red002.withAlpha(200),
            child: Center(child: Text("Tr", style: bodyMedium)),
          ),
          Container(
            color: red002.withAlpha(200),
            child: Center(child: Text("Ct", style: bodyMedium)),
          ),
          Container(
            color: red002.withAlpha(200),
            child: Center(child: Text("Pt", style: bodyMedium)),
          ),
          Container(
            color: red002.withAlpha(200),
            child: Center(child: Text("St", style: bodyMedium)),
          ),
          Container(
            padding: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: red002.withAlpha(200),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
              ),
            ),
            child: Center(child: Text("Sv", style: bodyMedium)),
          ),
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

class DatePickerDay extends StatelessWidget {
  const DatePickerDay({
    super.key,
    required this.date,
    this.disabled = false,
    this.currentMonth = true,
  });

  final DateTime date;
  final bool disabled;
  final bool currentMonth;

  @override
  Widget build(BuildContext context) {
    bool isToday =
        date.day == DateTime.now().day && date.month == DateTime.now().month;

    return Container(
      decoration: BoxDecoration(
        color: disabled
            ? Colors.black.withAlpha(currentMonth ? 10 : 35)
            : isToday
                ? Colors.white.withAlpha(60)
                : Colors.white12,
        borderRadius: BorderRadius.circular(5),
        border: Border(
          bottom: BorderSide(
            color: red003,
            width: 3,
          ),
        ),
      ),
      height: 20,
      width: 15,
      child: Center(child: Text("${date.day}", style: bodyMedium)),
    );
  }
}
