import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:flutter/material.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, Object>?> getMostPopularSchedule() async {
    try {
      final now = DateTime.now();
      final currentTimestamp = Timestamp.fromDate(now);

      final ticketsSnapshot = await _firestore.collection('tickets').get();

      Map<String, int> scheduleCountMap = {};
      List<Future<void>> scheduleFutures = [];

      for (var ticketDoc in ticketsSnapshot.docs) {
        final scheduleRef = ticketDoc.data()['schedule'] as DocumentReference;
        final scheduleId = scheduleRef.id;

        scheduleFutures.add(scheduleRef.get().then((scheduleDoc) {
          final scheduleData = scheduleDoc.data() as Map<String, dynamic>?;
          final scheduleTime = scheduleData?['time'] as Timestamp?;
          if (scheduleTime != null &&
              scheduleTime.compareTo(currentTimestamp) > 0) {
            scheduleCountMap[scheduleId] =
                (scheduleCountMap[scheduleId] ?? 0) + 1;
          }
        }));
      }

      await Future.wait(scheduleFutures);

      if (scheduleCountMap.isEmpty) {
        return null;
      }

      String mostPopularScheduleId = scheduleCountMap.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final scheduleDoc = await _firestore
          .collection('schedule')
          .doc(mostPopularScheduleId)
          .get();

      if (!scheduleDoc.exists) {
        return null;
      }

      final schedule = await ScheduleModel.fromMapAsync(
        scheduleDoc.data()!,
        scheduleDoc.id,
      );

      return {
        'schedule': schedule,
        'count': scheduleCountMap[mostPopularScheduleId] ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting most popular schedule: $e');
      return null;
    }
  }

  Future<Map<String, int>> getCounts() async {
    try {
      final moviesSnapshot = await _firestore.collection('movies').get();
      final usersSnapshot = await _firestore.collection('users').get();
      final offersSnapshot = await _firestore.collection('offers').get();
      final promocodesSnapshot =
          await _firestore.collection('promocodes').get();

      return {
        'users': usersSnapshot.docs.length,
        'movies': moviesSnapshot.docs.length,
        'offers': offersSnapshot.docs.length,
        'promocodes': promocodesSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting counts: $e');
      return {};
    }
  }
}
