import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:filmu_nams/controllers/widget_controller.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/controllers/promocode_controller.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/promocode_model.dart';
import 'package:intl/intl.dart';

class HallSeats extends StatefulWidget {
  const HallSeats({
    super.key,
    required this.scheduleId,
    required this.hallId,
  });

  final String scheduleId;
  final int hallId;

  @override
  State<HallSeats> createState() => _HallSeatsState();
}

class _HallSeatsState extends State<HallSeats> {
  int rowAmount = 5;
  int seatAmountPerRow = 10;

  int? selectedRowIndex = 0;
  int? selectedSeatIndex = 0;

  List<int?> chosenSeats = [];
  List<int?> takenSeats = [];

  bool isProcessingPayment = false;
  bool isLoading = false;

  String? currentScheduleId;
  PromocodeModel? submittedPromocode;
  final TextEditingController promocodeController = TextEditingController();
  final confettiController = ConfettiController();

  Style get style => Style.of(context);

  @override
  void initState() {
    super.initState();
    currentScheduleId = widget.scheduleId;
    getTakenSeats();
  }

  @override
  void dispose() {
    confettiController.dispose();
    promocodeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HallSeats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scheduleId != widget.scheduleId) {
      setState(() {
        selectedRowIndex = 0;
        selectedSeatIndex = 0;
        chosenSeats = [];
        currentScheduleId = widget.scheduleId;
      });
      getTakenSeats();
    }
  }

  int? selected() => seatAmountPerRow * selectedRowIndex! + selectedSeatIndex!;
  int getRowFromIndex(int? index) => index! ~/ seatAmountPerRow;
  int getColFromIndex(int? index) => index! % seatAmountPerRow;

  void selectSeat(int? index) {
    setState(() {
      selectedRowIndex = getRowFromIndex(index);
      selectedSeatIndex = getColFromIndex(index);
    });
  }

  void addTicket() {
    setState(() {
      chosenSeats.add(selected());
    });
  }

  void removeTicket(int index) {
    setState(() {
      chosenSeats.remove(chosenSeats[index]);
    });
  }

  Future<void> getTakenSeats() async {
    setState(() {
      isLoading = true;
    });
    final takenSeatsIndexes =
        await TicketController().getTakenSeatsByScheduleId(currentScheduleId!);
    setState(() {
      takenSeats = takenSeatsIndexes;
      isLoading = false;
    });
    selectFirstAvailableSeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: style.cardDecoration,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 8,
              children: [
                _buildHeader(),
                _buildSeatGrid(),
                if (chosenSeats.isNotEmpty) ...[
                  _buildTicketTable(),
                  if (submittedPromocode == null) _buildPromocodeInput(),
                ],
                _buildSubmitButton(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              maxBlastForce: 5,
              minBlastForce: 2,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.blue,
                Colors.pink,
                Colors.purple,
                Colors.red
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: style.cardDecoration,
      child: Row(
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: style.contrast.withAlpha(178),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            "${widget.hallId}. Zāle",
            style: GoogleFonts.poppins(
              color: style.contrast,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Column(
      spacing: 8,
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Container(
            decoration: style.cardDecoration,
            padding: const EdgeInsets.all(8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 10,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
              children: List.generate(50, (index) => _buildSeat(49 - index)),
            ),
          ),
          _buildLegend(),
          _buildAddTicketButton(),
        ],
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          _buildLegendItem('Pieejams', style.contrast.withAlpha(15)),
          _buildLegendItem('Aizņemts', style.contrast.withAlpha(50),
              icon: Icons.close),
          _buildLegendItem('Izvēlēts', const Color(0xFF2A2A2A)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, {IconData? icon}) {
    return IntrinsicWidth(
      child: Row(
        children: [
          Container(
            width: 20,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: style.contrast.withAlpha(25),
                width: 1,
              ),
            ),
            child: icon != null
                ? Icon(icon, size: 16, color: style.contrast.withAlpha(125))
                : null,
          ),
          const SizedBox(width: 8),
          FittedBox(
            child: Text(
              text,
              style: style.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(int? index) {
    final bool isSelected = index == selected();
    final bool isTaken = takenSeats.contains(index);
    final bool isChosen = chosenSeats.contains(index);

    return GestureDetector(
      onTap: () {
        if (!isTaken) {
          selectSeat(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isTaken
              ? style.contrast.withAlpha(50)
              : isSelected && !isChosen
                  ? const Color(0xFF2A2A2A)
                  : isChosen
                      ? style.contrast.withAlpha(25)
                      : style.contrast.withAlpha(15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected || isChosen
                ? style.contrast.withAlpha(76)
                : style.contrast.withAlpha(25),
            width: 1,
          ),
        ),
        child: isTaken
            ? Icon(
                Icons.close,
                size: 16,
                color: style.contrast.withAlpha(125),
              )
            : null,
      ),
    );
  }

  Widget _buildAddTicketButton() {
    return InkWell(
      onTap: () {
        if (!chosenSeats.contains(selected())) {
          addTicket();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: style.cardDecoration.copyWith(
          color: style.isDark ? style.cardDecoration.color : Colors.grey[200],
          boxShadow: [],
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: style.contrast.withAlpha(229),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pievienot biļeti',
              style: style.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: style.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          const SizedBox(height: 12),
          ...chosenSeats
              .asMap()
              .entries
              .map((entry) => _buildTicketRow(entry.key)),
          if (submittedPromocode != null) _buildPromocodeRow(),
          if (chosenSeats.isNotEmpty) _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text('Nr.', style: style.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Vieta',
            style: GoogleFonts.poppins(
              color: style.contrast.withAlpha(125),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text('Cena', style: style.bodyMedium),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildTicketRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: style.contrast.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${index + 1}',
              style: style.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rinda ${getRowFromIndex(chosenSeats[index]) + 1},\nVieta ${getColFromIndex(chosenSeats[index]) + 1}',
              style: style.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${getTicketPrice().toStringAsFixed(2)}€',
              style: GoogleFonts.poppins(
                color: style.contrast,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => removeTicket(index),
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red.withAlpha(178),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromocodeRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: style.contrast.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Atlaide',
              style: style.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              submittedPromocode!.name,
              style: style.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              getPromocodeSale(),
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: removePromocode,
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red.withAlpha(178),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Kopā: ',
            style: GoogleFonts.poppins(
              color: style.contrast,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            getSum(),
            style: GoogleFonts.poppins(
              color: style.contrast,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromocodeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: style.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promokods',
            style: GoogleFonts.poppins(
              color: style.contrast.withAlpha(178),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: promocodeController,
                    style: style.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ievadiet promokodu',
                      hintStyle: GoogleFonts.poppins(
                        color: style.contrast.withAlpha(76),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => submitPromocode(context),
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: isProcessingPayment
          ? const Center(child: CircularProgressIndicator())
          : FilledButton(
              onPressed: () {
                if (chosenSeats.isNotEmpty) {
                  processPayment(context);
                } else {
                  StylizedDialog.dialog(
                    Icons.error_outline,
                    context,
                    "Kļūda",
                    "Lūdzu, izvēlieties vismaz vienu vietu",
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.payment),
                  Text('Apmaksāt'),
                ],
              ),
            ),
    );
  }

  double getTicketPrice() => 4.0;

  double getTotalPrice() {
    final ticketPrice = getTicketPrice();
    final totalBeforeDiscount = chosenSeats.length * ticketPrice;
    final discount = submittedPromocode != null
        ? submittedPromocode!.amount != null
            ? submittedPromocode!.amount!
            : (totalBeforeDiscount * (submittedPromocode!.percents ?? 0) / 100)
        : 0;
    return totalBeforeDiscount - discount;
  }

  String getSum() => "${getTotalPrice().toStringAsFixed(2)}€";

  String getPromocodeSale() {
    final ticketPrice = getTicketPrice();
    final totalBeforeDiscount = chosenSeats.length * ticketPrice;
    return submittedPromocode!.amount != null
        ? "-${submittedPromocode!.amount!.toStringAsFixed(2).replaceAll('.', ',')}€"
        : "-${(totalBeforeDiscount * (submittedPromocode!.percents ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')}€";
  }

  Future<void> submitPromocode(BuildContext context) async {
    if (submittedPromocode != null) {
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Drīkst ievadīt tikai 1 promokodu",
      );
      return;
    }

    try {
      final response = await PromocodeController()
          .getPromocodeByName(promocodeController.text.toUpperCase());
      setState(() {
        submittedPromocode = response;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Promokods nav atrasts",
        );
      }
    }
  }

  void removePromocode() {
    setState(() {
      submittedPromocode = null;
      promocodeController.clear();
    });
  }

  Future<void> processPayment(BuildContext context) async {
    if (chosenSeats.isEmpty) {
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Lūdzu, izvēlieties vismaz vienu vietu",
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Lūdzu, ielogojieties, lai veiktu pirkumu",
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    try {
      final totalAmount = getTotalPrice();
      final seats = chosenSeats
          .map((seatIndex) =>
              "R${getRowFromIndex(seatIndex) + 1}-V${getColFromIndex(seatIndex) + 1}")
          .join(", ");

      final scheduleSnapshot = await FirebaseFirestore.instance
          .collection('schedule')
          .doc(widget.scheduleId)
          .get();
      final scheduleData = scheduleSnapshot.data() ?? {};
      final schedule =
          await ScheduleModel.fromMapAsync(scheduleData, widget.scheduleId);

      final description =
          "${schedule.movie.title}, vietas: $seats, ${formatDate(schedule.time)}, ${schedule.id}";

      if (context.mounted) {
        final success = await PaymentController().processPayment(
          context: context,
          amount: totalAmount,
          currency: 'eur',
          description: description,
          customerEmail: user.email,
          scheduleId: currentScheduleId!,
        );

        if (success) {
          saveTickets(description);
        }
      }
      setState(() {
        isProcessingPayment = false;
      });
    } catch (e) {
      debugPrint('Payment error: $e');

      if (context.mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Maksājuma kļūda",
          "Neizdevās apstrādāt maksājumu. Lūdzu, mēģiniet vēlāk.",
        );
      }

      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  int? findFirstAvailableSeat() {
    for (int i = 0; i < rowAmount * seatAmountPerRow; i++) {
      if (!takenSeats.contains(i) && !chosenSeats.contains(i)) {
        return i;
      }
    }
    return null;
  }

  void selectFirstAvailableSeat() {
    int? availableSeat = findFirstAvailableSeat();
    if (availableSeat != null) {
      setState(() {
        selectedRowIndex = getRowFromIndex(availableSeat);
        selectedSeatIndex = getColFromIndex(availableSeat);
      });
    }
  }

  Future<void> saveTickets(String desc) async {
    List<Map<String, int>> payload = chosenSeats
        .map((seatIndex) => {
              "row": getRowFromIndex(seatIndex),
              "seat": getColFromIndex(seatIndex),
            })
        .toList();

    try {
      await TicketController().createTicketsAndPaymentHistory(
        currentScheduleId!,
        payload,
        getTotalPrice(),
        desc,
      );

      await TicketWidgetController.updateTicketsWidget();

      for (var seat in chosenSeats) {
        setState(() {
          takenSeats.add(seat);
        });
      }
      setState(() {
        chosenSeats = [];
        submittedPromocode = null;
        promocodeController.clear();
      });
      selectFirstAvailableSeat();

      confettiController.play();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          confettiController.stop();
        }
      });
    } catch (e) {
      debugPrint('Error saving tickets: $e');
    }
  }

  String formatDate(Timestamp date) {
    return DateFormat('y.MM.dd. HH:mm').format(date.toDate());
  }
}
