import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/controllers/widget_controller.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/ticket_card.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/ticket_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TicketsView extends StatefulWidget {
  const TicketsView({super.key});

  @override
  State<TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<TicketsView>
    with SingleTickerProviderStateMixin {
  final TicketController _ticketController = TicketController();
  List<TicketModel> _tickets = [];
  bool isLoading = true;
  String errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      TicketWidgetController.updateTicketsWidget();
    } catch (e) {
      setState(() {
        errorMessage = 'Neizdevās ielādēt biļetes: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Style get style => Style.of(context);
  ThemeData get theme => Theme.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: style.primary,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
          decoration: style.cardDecoration,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -35,
                child: Icon(
                  Icons.confirmation_number,
                  color: Theme.of(context).colorScheme.primary.withAlpha(229),
                ),
              ),
              Text(
                'Manas biļetes',
                textAlign: TextAlign.center,
                style: style.displaySmall,
              ),
            ],
          ),
        ),
      ),
      body: Background(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 120),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(child: Text('Atkuālie', style: style.bodyMedium)),
                  Tab(child: Text('Izmantotie', style: style.bodyMedium)),
                  Tab(child: Text('Novecojušie', style: style.bodyMedium)),
                ],
                indicatorColor: theme.primaryColor,
                indicatorWeight: 2,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.primaryColor.withAlpha(125),
                dividerColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketList(_filterUpcomingTickets()),
                  _buildTicketList(_filterUsedTickets()),
                  _buildTicketList(_filterExpiredTickets()),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildTicketList(List<TicketModel> tickets) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.stretchedDots(
          color: style.contrast,
          size: 50,
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: GoogleFonts.poppins(
                color: Colors.red[300],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _loadTickets,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: style.contrast.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: style.contrast.withAlpha(25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Mēģināt vēlreiz',
                    style: GoogleFonts.poppins(
                      color: style.contrast.withAlpha(229),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: style.contrast.withAlpha(76),
            ),
            const SizedBox(height: 16),
            Text(
              'Nav biļešu šajā kategorijā',
              style: GoogleFonts.poppins(
                color: style.contrast.withAlpha(125),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Iegādājies biļeti, lai to redzētu šeit',
              style: GoogleFonts.poppins(
                color: style.contrast.withAlpha(76),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 16,
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
