import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:filmu_nams/controllers/notification_controller.dart';
import 'package:filmu_nams/models/payment_history_model.dart';
import 'package:filmu_nams/stripe_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';

class PaymentController {
  final String _paymentApiUrl = "https://api.stripe.com/v1/payment_intents";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initStripe() async {
    try {
      Stripe.publishableKey = StripeOptions().pk();
      await Stripe.instance.applySettings();
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Stripe: $e');
    }
  }

  Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    String? customerEmail,
    required String scheduleId,
  }) async {
    final schedule = _firestore.collection('schedule').doc(scheduleId);
    try {
      debugPrint("Processing payment of $amount $currency for: $description");

      final paymentIntentResult = await _createPaymentIntent(
        amount: (amount * 100).toInt(),
        currency: currency,
        description: description,
        customerEmail: customerEmail,
      );

      if (paymentIntentResult == null) {
        _showPaymentError(context, "Neizdevās izveidot maksājumu");
        generateUnsuccessfulHistory(
          amount: amount,
          schedule: schedule,
          reason: 'Failed to create payment intent',
          product: description,
        );
        return false;
      }

      final clientSecret = paymentIntentResult['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Filmu Nams',
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      _showPaymentSuccess(context);
      return true;
    } catch (e) {
      debugPrint("Payment error: $e");
      if (e is StripeException) {
        generateUnsuccessfulHistory(
          amount: amount,
          schedule: schedule,
          reason: 'Stripe: ${e.error.localizedMessage}',
          product: description,
        );
        _showPaymentError(context, "Stripe kļūda: ${e.error.localizedMessage}");
      } else {
        generateUnsuccessfulHistory(
          amount: amount,
          schedule: schedule,
          reason: "Payment error: $e",
          product: description,
        );
        _showPaymentError(context, "Maksājuma kļūda: $e");
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required String description,
    String? customerEmail,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': currency,
        'description': description,
        'payment_method_types[]': 'card',
      };

      if (customerEmail != null) {
        body['receipt_email'] = customerEmail;
      }

      final Dio dio = Dio();
      final response = await dio.post(_paymentApiUrl,
          data: body,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {'Authorization': 'Bearer ${StripeOptions().sk()}'},
          ));

      if (response.statusCode == 200) {
        debugPrint('Payment intent created successfully');
        return response.data;
      } else {
        debugPrint(
            'Failed to create payment intent: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  void _showPaymentSuccess(BuildContext context) {
    NotificationController().showNotification(
      1,
      "Maksājums veiksmīgs",
      "Jūsu maksājums ir veiksmīgi apstrādāts. Biļetes ir pieejāmas profila sadaļā.",
      "Jūsu maksājums ir veiksmīgi apstrādāts. Biļetes uz filmu ir pieejāmas profila sadaļā. Paldies, ka izvēlējāties mūs!\nAr cieņu, Filmu Nams",
      NotificationTypeEnum.payment,
    );
  }

  void _showPaymentError(BuildContext context, String message) {
    StylizedDialog.dialog(
      Icons.error_outline,
      context,
      "Maksājuma kļūda",
      message,
    );
  }

  void generateHistory(
      {required double amount,
      required DocumentReference schedule,
      required List<DocumentReference> tickets,
      required String product}) async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser?.uid);

    _firestore.collection('payments').add({
      'user': userRef,
      'amount': amount,
      'schedule': schedule,
      'tickets': tickets,
      'purchaseDate': Timestamp.now(),
      'status': 'completed',
      'product': product,
    }).catchError((error) {
      debugPrint("Failed to add payment history: $error");
      throw Exception("Failed to add payment history: $error");
    });
  }

  void generateUnsuccessfulHistory({
    required double amount,
    required DocumentReference schedule,
    required String reason,
    required String product,
  }) async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser?.uid);

    _firestore.collection('payments').add({
      'user': userRef,
      'amount': amount,
      'schedule': schedule,
      'purchaseDate': Timestamp.now(),
      'status': 'failed',
      'reason': reason,
      'product': product,
    }).catchError((error) {
      debugPrint("Failed to add unsuccessful payment history: $error");
      throw Exception("Failed to add unsuccessful payment history: $error");
    });
  }

  Future<List<PaymentHistoryModel>> getPaymentHistory() async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser?.uid);

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('payments')
          .where('user', isEqualTo: userRef)
          .orderBy('purchaseDate', descending: true)
          .get();
      final List<PaymentHistoryModel> paymentHistory = [];
      for (var doc in querySnapshot.docs) {
        final paymentHistoryModel = await PaymentHistoryModel.fromMapAsync(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        paymentHistory.add(paymentHistoryModel);
      }
      return paymentHistory;
    } catch (e) {
      debugPrint("Failed to retrieve payment history: $e");
      return [];
    }
  }
}

class PaymentHistoryStatusEnum {
  static const String completed = 'Apstrādāts';
  static const String failed = 'Neveiksmīgs';

  static String getStatus(String status) {
    switch (status) {
      case 'completed':
        return completed;
      case 'failed':
        return failed;
      default:
        return 'Nezināms';
    }
  }

  static bool isCompleted(String status) {
    return status == 'completed';
  }
}
