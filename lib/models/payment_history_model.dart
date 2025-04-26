import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/models/ticket_model.dart';

class PaymentHistoryModel {
  final String id;
  final double amount;
  final ScheduleModel schedule;
  final List<TicketModel>? tickets;
  final Timestamp purchaseDate;
  final String status;
  final String? reason;
  final String product;

  PaymentHistoryModel({
    required this.id,
    required this.amount,
    required this.schedule,
    this.tickets,
    required this.purchaseDate,
    required this.status,
    this.reason,
    required this.product,
  });

  static Future<PaymentHistoryModel> fromMapAsync(
    Map<String, dynamic> map,
    String id,
  ) async {
    final schedule = await map['schedule'].get();
    final scheduleModel = await ScheduleModel.fromMapAsync(
      schedule.data() as Map<String, dynamic>,
      schedule.id,
    );

    if (map['tickets'] == null) {
      return PaymentHistoryModel(
        id: id,
        amount: map['amount'],
        schedule: scheduleModel,
        tickets: null,
        purchaseDate: map['purchaseDate'],
        status: map['status'],
        reason: map['reason'],
        product: map['product'],
      );
    }

    final tickets = await Future.wait(
      (map['tickets'] as List<dynamic>).map((ticketRef) async {
        final ticketSnapshot = await ticketRef.get();
        return await TicketModel.fromMapAsync(
          ticketSnapshot.data() as Map<String, dynamic>,
          ticketSnapshot.id,
        );
      }),
    );

    return PaymentHistoryModel(
      id: id,
      amount: map['amount'],
      schedule: scheduleModel,
      tickets: tickets,
      purchaseDate: map['purchaseDate'],
      status: map['status'],
      reason: map['reason'],
      product: map['product'],
    );
  }
}
