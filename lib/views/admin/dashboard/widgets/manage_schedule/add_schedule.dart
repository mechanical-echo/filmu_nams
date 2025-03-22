import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/edit_schedule.dart';
import 'package:flutter/material.dart';

class AddSchedule extends StatelessWidget {
  const AddSchedule({
    super.key,
    required this.action,
  });

  final Function(String) action;

  @override
  Widget build(BuildContext context) {
    return EditSchedule(
      id: "",
      action: action,
    );
  }
}
