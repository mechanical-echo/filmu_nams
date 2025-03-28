import 'package:confetti/confetti.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/controllers/promocode_controller.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/promocode.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  int? selected() {
    return seatAmountPerRow * selectedRowIndex! + selectedSeatIndex!;
  }

  TextEditingController promocodeController = TextEditingController();

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
  void initState() {
    super.initState();
    currentScheduleId = widget.scheduleId;
    getTakenSeats();
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
    }
  }

  void removeTicket(int index) {
    setState(() {
      chosenSeats.remove(chosenSeats[index]);
    });
  }
  final confettiController = ConfettiController();

  @override
  void dispose() {
    super.dispose();
    confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          spacing: 10,
          children: [
            selectSeatDropdowns(),
            seatGrid(),
            ticketTable(),
            if (chosenSeats.isNotEmpty) promocodeInput(),
            submitButton(),
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
              Colors.red,
            ],
          ),
        ),
      ],
    );
  }

  Future<void> submitPromocode(BuildContext context) async {
    if (submittedPromocode != null) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Drīkst ievadīt tikai 1 promokodu",
      );
      return;
    }

    try {
      final response = await PromocodeController()
          .getPromocodeByName(promocodeController.text.toUpperCase());

      debugPrint("response: $response");

      setState(() {
        submittedPromocode = response;
      });
    } catch (E) {
      debugPrint(E.toString());
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Promokods nav atrasts",
      );
    }
  }

  promocodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          " Promokods",
          style: bodyLarge,
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                width: 250,
                height: 40,
                child: TextFormField(
                  controller: promocodeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton.filled(
                onPressed: () {
                  submitPromocode(context);
                },
                icon: Icon(Icons.add),
              ),
            )
          ],
        ),
      ],
    );
  }

  double getTicketPrice() {
    return 4.0;
  }

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

  String getSum() {
    return "${getTotalPrice().toStringAsFixed(2)}€";
  }

  Row selectSeatDropdowns() {
    final colors = ColorContext.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Expanded(
          child: Container(
            decoration: colors.classicDecorationSharper,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton(
              iconEnabledColor: Colors.white,
              underline: Container(),
              style: bodySmall,
              items: List.generate(
                rowAmount,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text("Rinda: ${index + 1}"),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedRowIndex = value;
                });
              },
              value: selectedRowIndex,
              isExpanded: true,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: colors.classicDecorationSharper,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton(
              iconEnabledColor: Colors.white,
              underline: Container(),
              style: bodySmall,
              items: List.generate(
                seatAmountPerRow,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text("Vieta: ${index + 1}"),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedSeatIndex = value;
                });
              },
              value: selectedSeatIndex,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Padding submitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 75.0),
      child: isProcessingPayment
          ? CircularProgressIndicator()
          : StylizedButton(
              action: () {
                if (chosenSeats.isNotEmpty) {
                  processPayment(context);
                } else {
                  StylizedDialog.alert(
                    context,
                    "Kļūda",
                    "Lūdzu, izvēlieties vismaz vienu vietu",
                  );
                }
              },
              title: "Apmaksāt",
              icon: Icons.payment,
            ),
    );
  }

  Future<void> processPayment(BuildContext context) async {
    if (chosenSeats.isEmpty) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Lūdzu, izvēlieties vismaz vienu vietu",
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      StylizedDialog.alert(
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
      StylizedDialog.alert(
        context,
        "Maksājuma kļūda",
        "Neizdevās apstrādāt maksājumu. Lūdzu, mēģiniet vēlāk.",
      );
    } finally {
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
    List<Map<String, int>> payload;

    payload = chosenSeats
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
      confettiController.play();
    } catch (e) {
      debugPrint('Error saving tickets: $e');
    }
  }

  Container ticketTable() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: darkDecorationSharper,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(0.8),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: smokeyWhite.withAlpha(75),
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: Text(
                        "Veids",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: smokeyWhite.withAlpha(200),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Apraksts",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: smokeyWhite.withAlpha(200),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Cena",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: smokeyWhite.withAlpha(200),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                ...List.generate(
                  chosenSeats.length,
                  (index) => ticketRow(index),
                ),
                if (submittedPromocode != null) promocodeRow(),
              ],
            ),
            if (chosenSeats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Kopā: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: smokeyWhite,
                      ),
                    ),
                    Text(
                      getSum(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: smokeyWhite,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  TableRow promocodeRow() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: smokeyWhite.withAlpha(40),
            width: 1,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Text(
            "Atlaide",
            style: TextStyle(
              color: smokeyWhite,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            submittedPromocode!.name,
            style: TextStyle(
              color: smokeyWhite,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            getPromocodeSale(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: smokeyWhite,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            removePromocode();
          },
          icon: Icon(
            Icons.remove_circle_outline,
            color: red003,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          splashRadius: 20,
        ),
      ],
    );
  }

  void removePromocode() {
    setState(() {
      submittedPromocode = null;
    });
  }

  String getPromocodeSale() {
    final ticketPrice = getTicketPrice();
    final totalBeforeDiscount = chosenSeats.length * ticketPrice;

    return submittedPromocode!.amount != null
        ? "-${submittedPromocode!.amount!.toStringAsFixed(2).replaceAll('.', ',')}€"
        : "-${(totalBeforeDiscount * (submittedPromocode!.percents ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')}€";
  }

  TableRow ticketRow(int index) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: smokeyWhite.withAlpha(40),
            width: 1,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Text(
            "Biļete",
            style: TextStyle(
              color: smokeyWhite,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "Rinda: ${getRowFromIndex(chosenSeats[index]) + 1}, Vieta: ${getColFromIndex(chosenSeats[index]) + 1}",
            style: TextStyle(
              color: smokeyWhite,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "${getTicketPrice().toStringAsFixed(2)}€",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: smokeyWhite,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            removeTicket(index);
          },
          icon: Icon(
            Icons.remove_circle_outline,
            color: red003,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          splashRadius: 20,
        ),
      ],
    );
  }

  Container seatGrid() {
    final colors = ColorContext.of(context);
    return Container(
      decoration: colors.classicDecorationSharper,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text("${widget.hallId}. Zale", style: bodyLarge),
          ),
          SizedBox(
            height: 220,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 10,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 0.8,
                    padding: const EdgeInsets.all(0),
                    children: List.generate(
                      50,
                      (index) => seat(49 - index),
                    ),
                  ),
          ),
          StylizedButton(
            action: () {
              if (!chosenSeats.contains(selected())) {
                addTicket();
              }
            },
            title: "Pievienot biļeti",
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  seat(int? index) {
    final colors = ColorContext.of(context);
    bool isSelected = index == selected();
    return GestureDetector(
      onTap: () {
        if (!takenSeats.contains(index)) {
          selectSeat(index);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: takenSeats.contains(index)
            ? classicDecorationDarkSharper
            : BoxDecoration(
                color: isSelected && !chosenSeats.contains(index)
                    ? colors.color003
                    : chosenSeats.contains(index)
                        ? Colors.white24
                        : colors.color002,
                border: Border.all(
                  color: colors.color003,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
        child: takenSeats.contains(index)
            ? Icon(
                Icons.close,
                size: 25,
                color: Colors.white24,
              )
            : null,
      ),
    );
  }
}
