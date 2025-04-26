import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/payment_history_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_payments/payment_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManagePayments extends StatefulWidget {
  const ManagePayments({super.key});

  @override
  State<ManagePayments> createState() => _ManagePaymentsState();
}

class _ManagePaymentsState extends State<ManagePayments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _paymentSubscription;
  final TextEditingController _searchController = TextEditingController();

  List<PaymentHistoryModel> payments = [];
  List<PaymentHistoryModel> filteredPayments = [];
  bool isLoading = true;
  String currentFilter = 'all';
  DateTime? selectedDate;
  String searchQuery = '';

  Style get style => Style.of(context);

  @override
  void initState() {
    super.initState();
    listenToPaymentChanges();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
      _applyFilters();
    });
  }

  void listenToPaymentChanges() {
    _paymentSubscription = _firestore
        .collection('payments')
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => PaymentHistoryModel.fromMapAsync(doc.data(), doc.id),
      );

      try {
        final items = await Future.wait(futures.toList());

        setState(() {
          payments = items;
          _applyFilters();
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Error processing payments: $e');
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (e) {
      debugPrint('Error listening to payment changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  void _applyFilters() {
    List<PaymentHistoryModel> result = List.from(payments);

    if (searchQuery.isNotEmpty) {
      result = result.where((payment) {
        return payment.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.schedule.id
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            payment.user.id.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (currentFilter != 'all') {
      result =
          result.where((payment) => payment.status == currentFilter).toList();
    }

    if (selectedDate != null) {
      final startOfDay =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      final endOfDay = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, 23, 59, 59);

      result = result.where((payment) {
        final paymentDate = payment.purchaseDate.toDate();
        return paymentDate.isAfter(startOfDay) &&
            paymentDate.isBefore(endOfDay);
      }).toList();
    }

    setState(() {
      filteredPayments = result;
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  double getTotalSuccessfulAmount() {
    double total = 0;
    for (var payment in filteredPayments) {
      if (payment.status == 'completed') {
        total += payment.amount;
      }
    }
    return total;
  }

  double getTotalFailedAmount() {
    double total = 0;
    for (var payment in filteredPayments) {
      if (payment.status == 'failed') {
        total += payment.amount;
      }
    }
    return total;
  }

  int getCompletedCount() {
    return filteredPayments
        .where((payment) => payment.status == 'completed')
        .length;
  }

  int getFailedCount() {
    return filteredPayments
        .where((payment) => payment.status == 'failed')
        .length;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: style.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Meklēt pēc maksājuma ID, lietotāja ID vai seansa ID',
                fillColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18.5,
                  horizontal: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: style.contrast,
                  ),
                  onPressed: _clearSearch,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: style.contrast,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _selectDate,
            child: Container(
              decoration: style.cardDecoration,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: style.contrast,
                  ),
                  Text(
                    selectedDate == null
                        ? 'Visi datumi'
                        : DateFormat('dd.MM.yyyy').format(selectedDate!),
                    style: style.titleSmall,
                  ),
                  if (selectedDate != null) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedDate = null;
                          _applyFilters();
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: style.contrast,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            decoration: style.cardDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: currentFilter,
              underline: SizedBox(),
              icon: Icon(Icons.filter_list),
              style: style.bodyMedium,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentFilter = newValue;
                    _applyFilters();
                  });
                }
              },
              items: <String>['all', 'completed', 'failed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'all'
                      ? 'Visi maksājumi'
                      : value == 'completed'
                          ? 'Veiksmīgi maksājumi'
                          : 'Neveiksmīgi maksājumi'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        spacing: 8,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1075) {
                return Row(
                  spacing: 8,
                  children: List.generate(
                    _buildStatCards().length,
                    (index) => index < 2
                        ? IntrinsicWidth(
                            child: _buildStatCards()[index],
                          )
                        : Expanded(
                            child: _buildStatCards()[index],
                          ),
                  ),
                );
              } else {
                return Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: _buildStatCards(),
                );
              }
            },
          ),
          _buildSearchBar(),
        ],
      ),
    );
  }

  List<Widget> _buildStatCards() {
    return [
      _buildStatCard(
        label: 'Veiksmīgo māk. summa',
        value: '${getTotalSuccessfulAmount().toStringAsFixed(2)}€',
        icon: Icons.euro,
        color: style.primary,
      ),
      _buildStatCard(
        label: 'Neveiksmīgo māk. summa',
        value: '${getTotalFailedAmount().toStringAsFixed(2)}€',
        icon: Icons.euro,
        color: style.primary,
        textColor: Colors.red.withOpacity(0.7),
      ),
      _buildStatCard(
        label: 'Veiksmīgi',
        value: '${getCompletedCount()}',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      _buildStatCard(
        label: 'Neveiksmīgi',
        value: '${getFailedCount()}',
        icon: Icons.error_outline,
        color: Colors.red,
      ),
      _buildStatCard(
        label: 'Kopā',
        value: '${filteredPayments.length}',
        icon: Icons.numbers,
        color: style.secondary,
      ),
      _buildStatCard(
        label: 'Neveiksmīgi',
        value: '${getFailedCount()}',
        icon: Icons.error_outline,
        color: Colors.red,
      ),
    ];
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: style.bodySmall.copyWith(
                  color: style.contrast.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: style.headlineMedium.copyWith(color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Style.of(context).primary,
              onPrimary: Style.of(context).onPrimary,
              surface: Style.of(context).surface,
              onSurface: Style.of(context).onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && (selectedDate == null || picked != selectedDate)) {
      setState(() {
        selectedDate = picked;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double calculatedWidth = width * 0.9;

    return Column(
      children: [
        _buildHeader(calculatedWidth),
        _buildFilterBar(),
        Expanded(
          child: Container(
            decoration: style.cardDecoration,
            width: calculatedWidth,
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 100,
                    ),
                  )
                : filteredPayments.isEmpty
                    ? Center(
                        child: Text(
                          "Nav atrasts neviens maksājums ar atlasītajiem filtriem",
                          style: style.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPayments.length,
                        itemBuilder: (context, index) {
                          return PaymentCard(
                            data: filteredPayments[index],
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double calculatedWidth) {
    return Container(
      width: calculatedWidth,
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: [
          IntrinsicWidth(
            child: Row(
              spacing: 15,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Maksājumi${selectedDate != null ? " (${DateFormat('dd.MM.yyyy').format(selectedDate!)})" : ""}",
                    style: style.displayLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
