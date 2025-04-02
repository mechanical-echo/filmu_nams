import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ticket.dart';

class TicketController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTickets(String id, List<Map<String, int>> seats) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userRef = _firestore.collection('users').doc(user!.uid);
      final scheduleRef = _firestore.collection('schedule').doc(id);

      for (var seat in seats) {
        await _firestore.collection('tickets').add({
          'schedule': scheduleRef,
          'user': userRef,
          'seat': {
            'row': seat['row'],
            'seat': seat['seat'],
          },
          'purchaseDate': Timestamp.now(),
          'status': TicketStatusEnum.unused,
        });
      }
    } catch (e) {
      debugPrint('Error creating tickets: $e');
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }
      
      final userRef = _firestore.collection('users').doc(user.uid);
      
      final QuerySnapshot querySnapshot = await _firestore
          .collection('tickets')
          .where('user', isEqualTo: userRef)
          .orderBy('purchaseDate', descending: true)
          .get();
      
      List<TicketModel> tickets = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final ticket = await TicketModel.fromMapAsync(
            doc.data() as Map<String, dynamic>, 
            doc.id
          );
          tickets.add(ticket);
        } catch (e) {
          debugPrint('Error parsing ticket: $e');
        }
      }
      
      return tickets;
    } catch (e) {
      debugPrint('Error getting user tickets: $e');
      return [];
    }
  }

  Future<List<int>> getTakenSeatsByScheduleId(String id) async {
    try {
      final scheduleRef = _firestore.collection('schedule').doc(id);

      final QuerySnapshot querySnapshot = await _firestore
          .collection('tickets')
          .where('schedule', isEqualTo: scheduleRef)
          .get();

      List<int> seats = [];

      for (var doc in querySnapshot.docs) {
        final ticket = await TicketModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id);
        seats.add(getIndexFromRowCol(ticket.seat['row']!, ticket.seat['seat']!));
      }

      return seats;
    } catch (e) {
      debugPrint('Error getting taken seats: $e');
      return [];
    }
  }

  int getIndexFromRowCol(int row, int col) => row * 10 + col;
}

class TicketStatusEnum {
  static const String unused = 'unused';
  static const String used = 'used';
  static const String expiredUnused = 'expired/unused';
  static const String expiredUsed = 'expired/used';
}