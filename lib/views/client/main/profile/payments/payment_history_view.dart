import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/models/payment_history_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  PaymentController paymentController = PaymentController();
  Style get style => Style.of(context);

  List<PaymentHistoryModel> paymentHistory = [];

  bool isLoading = true;

  void fetchPaymentHistory() {
    paymentController.getPaymentHistory().then((response) {
      setState(() {
        paymentHistory = response;
      });
    }).catchError((error) {
      debugPrint('Error fetching payment history: $error');
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Maksājumu vēsture',
          style: style.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Background(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
              ),
              isLoading
                  ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white60,
                      size: 50,
                    )
                  : paymentHistory.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: paymentHistory.length,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemBuilder: (context, index) {
                              final payment = paymentHistory[index];
                              return listItem(payment);
                            },
                          ),
                        )
                      : noHistoryMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget listItem(PaymentHistoryModel payment) {
    return Tooltip(
      message: 'Maksājuma id ir veiksmīgi kopēts',
      showDuration: const Duration(seconds: 2),
      onTriggered: () {
        Clipboard.setData(
          ClipboardData(text: payment.id),
        );
      },
      preferBelow: true,
      child: Container(
        decoration: style.cardDecoration,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(
            truncateProductName(payment),
            style: style.bodyLarge,
          ),
          subtitle: Column(
            children: [
              Divider(),
              Text(
                'Maksājuma id: ${payment.id}\nSeansa id: ${payment.schedule.id}\nDatums: ${formatDate(payment.purchaseDate)}\nStatuss: ${PaymentHistoryStatusEnum.getStatus(payment.status)}',
                style: style.bodyMedium,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${payment.amount} €',
                style: style.bodyLarge,
              ),
              Icon(
                PaymentHistoryStatusEnum.isCompleted(payment.status)
                    ? Icons.check_circle
                    : Icons.error,
                color: PaymentHistoryStatusEnum.isCompleted(payment.status)
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column noHistoryMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.payment,
          size: 60,
          color: Colors.grey[500],
        ),
        Text(
          'Nav maksājumu vēstures',
          style: style.bodyLarge,
        ),
      ],
    );
  }

  String formatDate(Timestamp date) {
    return DateFormat('y.MM.dd. HH:mm').format(date.toDate());
  }

  String truncateProductName(PaymentHistoryModel payment) {
    return payment.product
        .replaceAll(', ${payment.schedule.id}', '')
        .replaceAll(', ', '\n');
  }
}
