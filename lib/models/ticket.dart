import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/models/user.dart';

class TicketModel {
  ScheduleModel schedule;
  UserModel user;
  String id;
  Map<String, dynamic> seat;

  TicketModel({
    required this.id,
    required this.schedule,
    required this.user,
    required this.seat,
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
      id: id,
      seat: map['seat'],
    );
  }
}
