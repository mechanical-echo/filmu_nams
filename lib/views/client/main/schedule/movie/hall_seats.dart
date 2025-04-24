import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/controllers/promocode_controller.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/promocode_model.dart';

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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            "${widget.hallId}. Zāle",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 10,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
                children: List.generate(50, (index) => _buildSeat(49 - index)),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 16),
            _buildAddTicketButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Pieejams', Colors.white.withOpacity(0.05)),
        const SizedBox(width: 16),
        _buildLegendItem('Aizņemts', Colors.white.withOpacity(0.2),
            icon: Icons.close),
        const SizedBox(width: 16),
        _buildLegendItem('Izvēlēts', const Color(0xFF2A2A2A)),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color, {IconData? icon}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 16, color: Colors.white.withOpacity(0.5))
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
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
              ? Colors.white.withOpacity(0.2)
              : isSelected && !isChosen
                  ? const Color(0xFF2A2A2A)
                  : isChosen
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected || isChosen
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: isTaken
            ? Icon(
                Icons.close,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              )
            : null,
      ),
    );
  }

  Widget _buildAddTicketButton() {
    return TextButton(
      onPressed: () {
        if (!chosenSeats.contains(selected())) {
          addTicket();
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF2A2A2A),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Pievienot biļeti',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
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
          flex: 2,
          child: Text(
            'Biļete',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Vieta',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Cena',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Biļete ${index + 1}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Rinda ${getRowFromIndex(chosenSeats[index]) + 1}, Vieta ${getColFromIndex(chosenSeats[index]) + 1}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${getTicketPrice().toStringAsFixed(2)}€',
              style: GoogleFonts.poppins(
                color: Colors.white,
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
                color: Colors.red.withOpacity(0.7),
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
            color: Colors.white.withOpacity(0.1),
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
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              submittedPromocode!.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
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
                color: Colors.red.withOpacity(0.7),
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
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            getSum(),
            style: GoogleFonts.poppins(
              color: Colors.white,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promokods',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  // decoration: BoxDecoration(
                  //   color: const Color(0xFF2A2A2A),
                  //   borderRadius: BorderRadius.circular(8),
                  //   border: Border.all(
                  //     color: Colors.white.withOpacity(0.1),
                  //     width: 1,
                  //   ),
                  // ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: promocodeController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ievadiet promokodu',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => submitPromocode(context),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  padding: const EdgeInsets.all(12),
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
          : TextButton(
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
              style: TextButton.styleFrom(
                backgroundColor: chosenSeats.isEmpty
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFF2A2A2A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payment,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Apmaksāt',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Promokods nav atrasts",
      );
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

      final description =
          "Filmu Nams biļetes, ${widget.hallId}. zāle, vietas: $seats";

      final success = await PaymentController().processPayment(
        context: context,
        amount: totalAmount,
        currency: 'eur',
        description: description,
        customerEmail: user.email,
      );

      if (success) {
        saveTickets();
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Maksājuma kļūda",
        "Neizdevās apstrādāt maksājumu. Lūdzu, mēģiniet vēlāk.",
      );

      if (mounted) {
        setState(() {
          isProcessingPayment = false;
        });
      }
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

  Future<void> saveTickets() async {
    List<Map<String, int>> payload = chosenSeats
        .map((seatIndex) => {
              "row": getRowFromIndex(seatIndex),
              "seat": getColFromIndex(seatIndex),
            })
        .toList();

    try {
      await TicketController().createTickets(currentScheduleId!, payload);
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

      // Play confetti once
      confettiController.play();
      // Stop after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          confettiController.stop();
        }
      });
    } catch (e) {
      debugPrint('Error saving tickets: $e');
    }
  }
}
