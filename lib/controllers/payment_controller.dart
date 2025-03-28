import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:filmu_nams/stripe_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';

class PaymentController {
  final String _paymentApiUrl = "https://api.stripe.com/v1/payment_intents";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }) async {
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
        _showPaymentError(context, "Stripe kļūda: ${e.error.localizedMessage}");
      } else {
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
      final response = await dio.post(
          _paymentApiUrl,
          data: body,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              'Authorization': 'Bearer ${StripeOptions().sk()}'
            },
          )
      );

      if (response.statusCode == 200) {
        debugPrint('Payment intent created successfully');
        return response.data;
      } else {
        debugPrint('Failed to create payment intent: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  void _showPaymentSuccess(BuildContext context) {
    StylizedDialog.alert(
      context,
      "Maksājums veiksmīgs",
      "Jūsu maksājums ir veiksmīgi apstrādāts. Biļetes ir pieejāmas profila sadaļā.",
    );
  }

  void _showPaymentError(BuildContext context, String message) {
    StylizedDialog.alert(
      context,
      "Maksājuma kļūda",
      message,
    );
  }

  Future<void> createTickets(String id, List<Map<String, int>> seats) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userRef = _firestore.collection('users').doc(user!.uid);
      final scheduleRef = _firestore.collection('schedule').doc(id);

      for (var seat in seats) {
        await _firestore.collection('tickets').add({
          'schedule': scheduleRef,
          'userId': userRef,
          'seat': {
            'row': seat['row'],
            'seat': seat['seat'],
          },
        });
      }
    } catch (e) {
      debugPrint('Error creating tickets: $e');
    }
  }
}