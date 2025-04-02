import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:intl/intl.dart';

class TicketModel {
  final ScheduleModel schedule;
  final UserModel user;
  final String id;
  final Map<String, dynamic> seat;
  final Timestamp purchaseDate;

  TicketModel({
    required this.id,
    required this.schedule,
    required this.user,
    required this.seat,
    required this.purchaseDate,
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
      purchaseDate: map['purchaseDate'] ?? Timestamp.now(),
    );
  }
  
  String getFormattedDate() {
    final date = purchaseDate.toDate();
    return DateFormat("dd.MM.yyyy.").format(date);
  }
  
  String getFormattedShowTime() {
    final date = schedule.time.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String getFormattedShowDate() {
    final date = schedule.time.toDate();
    return DateFormat("dd.MM.yyyy.").format(date);
  }
  
  String getSeatInfo() {
    final row = seat['row'] + 1;
    final seatNum = seat['seat'] + 1;
    return 'Rinda $row, Sēdvieta $seatNum';
  }
}
