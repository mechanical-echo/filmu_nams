import 'dart:ui';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.onDateSelected,
    this.availableDates,
  });

  final void Function(DateTime) onDateSelected;
  final List<DateTime>? availableDates;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker>
    with SingleTickerProviderStateMixin {
  late DateTime selectedDate;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    final style = Style.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: style.isDark
              ? style.opaqueCardDecoration
              : style.cardDecoration.copyWith(
                  borderRadius: BorderRadius.circular(25),
                ),
          height: 400,
          width: 350,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildHeader(),
                _buildWeekDays(),
                _buildMonth(
                  daysFromPrevMonth,
                  lastDayPrevMonth,
                  currentMonthDays,
                  daysFromNextMonth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(76),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: previousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: theme.colorScheme.onSurface.withAlpha(229),
              size: 28,
            ),
          ),
          Text(
            "${DateFormat(DateFormat.YEAR).format(selectedDate)} ${capitalize(DateFormat(DateFormat.STANDALONE_MONTH, 'lv').format(selectedDate))}",
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            onPressed: nextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withAlpha(229),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final theme = Theme.of(context);
    final weekDays = ['Pr', 'Ot', 'Tr', 'Ct', 'Pt', 'St', 'Sv'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays
            .map((day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface.withAlpha(125),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMonth(
    int daysFromPrevMonth,
    DateTime lastDayPrevMonth,
    int currentMonthDays,
    int daysFromNextMonth,
  ) {
    return Expanded(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          ...List.generate(
            daysFromPrevMonth,
            (index) => _buildDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                lastDayPrevMonth.day - daysFromPrevMonth + index + 1,
              ),
              isCurrentMonth: false,
            ),
          ),
          ...List.generate(
            currentMonthDays,
            (index) => _buildDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month,
                index + 1,
              ),
              isCurrentMonth: true,
            ),
          ),
          ...List.generate(
            daysFromNextMonth,
            (index) => _buildDay(
              date: DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                index + 1,
              ),
              isCurrentMonth: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay({
    required DateTime date,
    required bool isCurrentMonth,
  }) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    final isAvailable = widget.availableDates == null ||
        widget.availableDates!.any((d) =>
            d.day == date.day && d.month == date.month && d.year == date.year);

    final isEnabled = isCurrentMonth && isAvailable;

    final theme = Theme.of(context);
    return GestureDetector(
      onTap: isEnabled ? () => widget.onDateSelected(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isToday
              ? theme.colorScheme.primary.withAlpha(36)
              : isEnabled
                  ? theme.colorScheme.onSurface.withAlpha(15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: const Color(0xFF3A3A3A), width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            "${date.day}",
            style: GoogleFonts.poppins(
              color: isEnabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withAlpha(76),
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
