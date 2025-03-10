import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/models/user.dart';

class TicketModel {
  ScheduleModel schedule;
  UserModel user;

  TicketModel({
    required this.schedule,
    required this.user,
  });

  static Future<TicketModel> fromMapAsync(
    Map<String, dynamic> map,
    String id,
  ) async {
    final scheduleSnapshot = await map['schedule'].get();
    final userSnapshot = await map['user'].get();

    final schedule = await ScheduleModel.fromMapAsync(
      scheduleSnapshot.data(),
      scheduleSnapshot.id,
    );

    final user = UserModel.fromMap(
      userSnapshot.data(),
      userSnapshot.id,
    );

    return TicketModel(
      schedule: schedule,
      user: user,
    );
  }
}
