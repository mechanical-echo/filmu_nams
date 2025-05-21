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
  Map<String, bool> expandedItems = {};
  Map<String, bool> hoveredItems = {};

  bool isLoading = true;

  void fetchPaymentHistory() {
    paymentController.getPaymentHistory().then((response) {
      setState(() {
        paymentHistory = response;
        for (var payment in response) {
          expandedItems[payment.id] = false;
          hoveredItems[payment.id] = false;
        }
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
                              horizontal: 10,
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
    final isCompleted = PaymentHistoryStatusEnum.isCompleted(payment.status);
    final isExpanded = expandedItems[payment.id] ?? false;
    final isHovered = hoveredItems[payment.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        onTap: () => setState(() => expandedItems[payment.id] = !isExpanded),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration:
              isHovered ? style.activeCardDecoration : style.cardDecoration,
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${payment.amount.toStringAsFixed(2)}€',
                      style: style.headlineMedium.copyWith(
                        color: isCompleted
                            ? style.contrast
                            : Colors.red.withAlpha(178),
                      ),
                    ),
                    Text(
                      PaymentHistoryStatusEnum.getStatus(payment.status),
                      style: style.bodyLarge.copyWith(
                        color: isCompleted ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: 'Klikšķiniet, lai kopētu',
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: payment.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Maksājuma ID nokopēts'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.receipt,
                                  size: 16, color: style.primary),
                              const SizedBox(width: 8),
                              Text(
                                'ID: ${payment.id.substring(0, payment.id.length - 15)}...',
                                style: style.titleMedium,
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.copy,
                                  size: 14,
                                  color: style.contrast.withAlpha(125)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(payment.purchaseDate),
                        style: style.bodyMedium
                            .copyWith(color: style.contrast.withAlpha(178)),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateProductName(payment),
                          style: style.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          spacing: 4,
                          children: [
                            Icon(
                              Icons.meeting_room,
                              size: 14,
                              color: style.contrast.withAlpha(125),
                            ),
                            Text(
                              '${payment.schedule.id.substring(0, payment.schedule.id.length - 10)}...',
                              style: style.bodySmall.copyWith(
                                color: style.contrast.withAlpha(178),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: style.primary,
                    ),
                    onPressed: () =>
                        setState(() => expandedItems[payment.id] = !isExpanded),
                  ),
                ],
              ),
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(25),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withAlpha(76),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maksājuma detaļas',
                        style: style.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      buildDetailRow(
                        'Produkts',
                        payment.product,
                        copy: true,
                        copyText: payment.schedule.id,
                        copyLabel: 'Saraksta ID nokopēts',
                      ),
                      buildDetailRow(
                        'Datums',
                        formatDate(payment.purchaseDate),
                      ),
                      buildDetailRow(
                        'Statuss',
                        PaymentHistoryStatusEnum.getStatus(payment.status),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(
    String label,
    String value, {
    bool copy = false,
    String copyText = '',
    String copyLabel = 'Teksts nokopēts',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: style.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: copy
                ? InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: copyText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(copyLabel),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: style.bodyMedium,
                          ),
                        ),
                        Tooltip(
                          message: 'Klikšķiniet, lai kopētu',
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: style.contrast.withAlpha(125),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: style.bodyMedium,
                  ),
          ),
        ],
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
    return DateFormat('dd.MM.yyyy HH:mm').format(date.toDate());
  }

  String truncateProductName(PaymentHistoryModel payment) {
    return payment.product
        .replaceAll(', ${payment.schedule.id}', '')
        .replaceAll(', ', '\n');
  }
}
