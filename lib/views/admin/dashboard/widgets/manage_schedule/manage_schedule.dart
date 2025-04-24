import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/edit_schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/schedule_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSchedule extends StatefulWidget {
  const ManageSchedule({super.key});

  @override
  State<ManageSchedule> createState() => _ManageScheduleState();
}

class _ManageScheduleState extends State<ManageSchedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _scheduleSubscription;

  List<ScheduleModel> scheduleItems = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    listenToScheduleChanges();
  }

  void listenToScheduleChanges() {
    final startOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    _scheduleSubscription = _firestore
        .collection('schedule')
        .where('time', isGreaterThanOrEqualTo: startTimestamp)
        .where('time', isLessThanOrEqualTo: endTimestamp)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        scheduleItems = items;
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to schedule changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditScheduleDialog(dateTime: selectedDate);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      isLoading = true;
    });

    _scheduleSubscription?.cancel();
    listenToScheduleChanges();
  }

  Widget _buildDateSelector() {
    final theme = Style.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => onDateSelected(
              selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          InkWell(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null) {
                onDateSelected(pickedDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('EEEE, d MMMM y', 'lv').format(selectedDate),
                style: theme.titleMedium,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () => onDateSelected(
              selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(),
        ManageScreen(
          height: 100,
          count: scheduleItems.length,
          isLoading: isLoading,
          itemGenerator: (index) => ScheduleCard(
            data: scheduleItems[index],
            onEdit: (id) {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return EditScheduleDialog(id: id);
                },
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );
            },
          ),
          title:
              "Saraksts - ${DateFormat('d MMMM y', 'lv').format(selectedDate)}",
          onCreate: showAddDialog,
        ),
      ],
    );
  }
}
