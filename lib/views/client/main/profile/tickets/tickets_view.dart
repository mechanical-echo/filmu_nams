import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tab.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/ticket.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/ticket_card.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/ticket_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketsView extends StatefulWidget {
  const TicketsView({super.key});

  @override
  State<TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<TicketsView> {
  final TicketController _ticketController = TicketController();
  List<TicketModel> _tickets = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final tickets = await _ticketController.getUserTickets();
      setState(() {
        _tickets = tickets;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Neizdevās ielādēt biļetes: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: colors.color001,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: title(colors),
      ),
      body: Background(
        child: body(),
      ),
    );
  }

  Container title(ColorContext colors) {
    return Container(
      decoration: colors.classicDecorationDark,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      margin: const EdgeInsets.only(bottom: 5),
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -35,
            child: Icon(
              Icons.confirmation_number,
              color: Colors.white,
            ),
          ),
          Text(
            'Manas biļetes',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              child: const Text('Mēģināt vēlreiz'),
            ),
          ],
        ),
      );
    }

    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Nav iegādātu biļešu',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Iegādājies biļeti, lai to redzētu šeit',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Filter tickets by status
    List<TicketModel> usedTickets = _filterUsedTickets();
    List<TicketModel> upcomingTickets = _filterUpcomingTickets();
    List<TicketModel> expiredTickets = _filterExpiredTickets();

    final colors = ColorContext.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 126),
      child: StylizedTabs(
        fontSize: 14,
        tabs: [
          StylizedTabPage(
            title: StylizedTabTitle.text("Tuvākie"),
            child: _ticketListView(upcomingTickets),
          ),
          StylizedTabPage(
            title: StylizedTabTitle.text("Izmantotie"),
            child: _ticketListView(usedTickets),
          ),
          StylizedTabPage(
            title: StylizedTabTitle.text("Novecojušie"),
            child: _ticketListView(expiredTickets),
          ),
        ],
      ),
    );
  }

  List<TicketModel> _filterUsedTickets() {
    return [];
  }

  List<TicketModel> _filterUpcomingTickets() {
    DateTime now = DateTime.now();
    return _tickets.where((ticket) {
      DateTime showtime = ticket.schedule.time.toDate();
      return showtime.isAfter(now);
    }).toList();
  }

  List<TicketModel> _filterExpiredTickets() {
    DateTime now = DateTime.now();
    return _tickets.where((ticket) {
      DateTime showtime = ticket.schedule.time.toDate();
      return showtime.isBefore(now);
    }).toList();
  }

  Widget _ticketListView(List<TicketModel> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            'Nav biļešu šajā kategorijā',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          right: 16,
          bottom: 50,
          left: 16,
        ),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return TicketCard(
            ticket: tickets[index],
            onTap: () => _showTicketDetail(tickets[index]),
          );
        },
      ),
    );
  }

  void _showTicketDetail(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TicketDetailDialog(ticket: ticket);
      },
    );
  }
}