import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:flutter/widgets.dart';

class PaymentHistoryModel {
  final String id;
  final dynamic amount;
  final ScheduleModel schedule;
  final List<TicketModel?>? tickets;
  final Timestamp purchaseDate;
  final String status;
  final String? reason;
  final String product;
  final UserModel user;

  PaymentHistoryModel({
    required this.id,
    required this.amount,
    required this.schedule,
    this.tickets,
    required this.purchaseDate,
    required this.status,
    this.reason,
    required this.product,
    required this.user,
  });

  static Future<PaymentHistoryModel> fromMapAsync(
    Map<String, dynamic> map,
    String id,
  ) async {
    dynamic scheduleModel;
    dynamic userModel;
    try {
      final schedule = await map['schedule'].get();
      scheduleModel = await ScheduleModel.fromMapAsync(
        schedule.data() as Map<String, dynamic>,
        schedule.id,
      );
    } catch (e) {
      debugPrint("err1");
    }

    try {
      final user = await map['user'].get();
      userModel = UserModel.fromMap(
        user.data() as Map<String, dynamic>,
        user.id,
      );
    } catch (e) {
      debugPrint("err2");
    }

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
        user: userModel,
      );
    }

    final tickets = await Future.wait(
      (map['tickets'] as List<dynamic>).map((ticketRef) async {
        final ticketSnapshot = await ticketRef.get();
        if (ticketSnapshot.data() == null) {
          return null;
        }
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
      user: userModel,
    );
  }
}
