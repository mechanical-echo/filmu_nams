import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';

class TicketWidgetController {
  static const String appGroupId = 'group.filmuNams';
  static const String iOSWidgetName = 'FilmuNamsWidget';
  static const String androidWidgetName = 'FilmuNamsWidget';

  static const String ticketsDataKey = 'tickets_data';
  static const String ticketsCountKey = 'tickets_count';
  static const String lastUpdatedKey = 'last_updated';
  static const String debugKey = 'debug_info';

  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.saveWidgetData(debugKey, 'Debug value set at ${DateTime.now().toString()}');
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to initialize TicketWidgetManager: $e');
    }
  }

  static Future<void> updateTicketsWidget() async {
    try {
      final ticketController = TicketController();
      final tickets = await ticketController.getUserTickets();

      debugPrint('TicketWidgetManager: Found ${tickets.length} tickets total');

      if (tickets.isEmpty) {
        await HomeWidget.saveWidgetData(ticketsDataKey, "[]");
        await HomeWidget.saveWidgetData(ticketsCountKey, 0);
        await HomeWidget.saveWidgetData(
            lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

        debugPrint('TicketWidgetManager: Saved empty ticket data to widget');

        await HomeWidget.updateWidget(
          iOSName: iOSWidgetName,
          androidName: androidWidgetName,
        );
        return;
      }

      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);

      final recentTickets = tickets.where((ticket) => ticket.schedule.time.toDate().isAfter(startOfDay)).take(3).toList();

      final ticketsData = recentTickets
          .map((ticket) => {
                'id': ticket.id,
                'movieTitle': ticket.schedule.movie.title,
                'posterUrl': ticket.schedule.movie.posterUrl,
                'date': ticket.schedule.time.toDate().millisecondsSinceEpoch,
                'hall': ticket.schedule.hall,
                'seat': '${ticket.seat['row'] + 1}-${ticket.seat['seat'] + 1}',
                'formattedTime': ticket.getFormattedShowTime(),
                'formattedDate': ticket.getFormattedShowDate(),
              })
          .toList();

      final ticketsJson = jsonEncode(ticketsData);
      debugPrint('TicketWidgetManager: JSON data to save: $ticketsJson');

      await HomeWidget.saveWidgetData(ticketsDataKey, ticketsJson);
      await HomeWidget.saveWidgetData(ticketsCountKey, recentTickets.length);
      await HomeWidget.saveWidgetData(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      debugPrint('TicketWidgetManager: Widget updated with ${recentTickets.length} tickets');
    } catch (e, stackTrace) {
      debugPrint('Failed to update tickets widget: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
