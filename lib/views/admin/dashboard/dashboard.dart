import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/dashboard_controller.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _scheduleSubscription;
  Style get style => Style.of(context);

  List<ScheduleModel> scheduleItems = [];
  ScheduleModel? mostPopularSchedule;

  int mostPopularScheduleTicketCount = 0;

  int movieCount = 0;
  int userCount = 0;
  int offerCount = 0;
  int promoCodeCount = 0;

  void listenToScheduleChanges() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    _scheduleSubscription = _firestore
        .collection('schedule')
        .where('time', isGreaterThanOrEqualTo: startTimestamp)
        .where('time', isLessThanOrEqualTo: endTimestamp)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        scheduleItems = items;
      });
    }, onError: (e) {
      debugPrint('Error listening to schedule changes: $e');
    });
  }

  void getMostPopularSchedule() {
    DashboardController().getMostPopularSchedule().then((result) {
      if (result != null) {
        setState(() {
          mostPopularSchedule = result['schedule'] as ScheduleModel;
          mostPopularScheduleTicketCount = result['count'] as int;
        });
      }
    }).catchError((error) {
      debugPrint('Error fetching most popular schedule: $error');
    });
  }

  void fetchCount() {
    DashboardController().getCounts().then((result) {
      setState(() {
        movieCount = int.parse(result['movies']?.toString() ?? '0');
        userCount = int.parse(result['users']?.toString() ?? '0');
        offerCount = int.parse(result['offers']?.toString() ?? '0');
        promoCodeCount = int.parse(result['promocodes']?.toString() ?? '0');
      });
    }).catchError((error) {
      debugPrint('Error fetching counts: $error');
    });
  }

  @override
  void initState() {
    listenToScheduleChanges();
    getMostPopularSchedule();
    fetchCount();
    super.initState();
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 25,
      children: [
        Container(
          width: 870,
          decoration: style.cardDecoration,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            spacing: 16,
            children: [
              Wrap(
                spacing: 10,
                children: [
                  Text(
                    "Filmu Nams",
                    style: style.displayLarge.copyWith(
                      color: style.primary,
                    ),
                  ),
                  Text(
                    "Administrācijas panelis",
                    style: style.displayLarge,
                  ),
                ],
              ),
              Text(
                "Šeit Jūs varat pārvaldīt aplikācijā pieejamas filmas, lietotājus, utt.",
                style: style.headlineMedium,
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 25,
          runSpacing: 25,
          children: [
            Column(
              spacing: 25,
              children: [
                schedule(),
                Container(
                  width: 655,
                  height: 118,
                  decoration: style.cardDecoration,
                  padding: const EdgeInsets.only(left: 30, right: 12),
                  child: mostPopularSchedule == null
                      ? Center(
                          child: Text(
                            "Uz šodienas un nākotnes seansem nopirkto biļešu nav",
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Visvairāk biļešu:",
                              style: style.displaySmall,
                            ),
                            Container(
                              decoration: style.roundCardDecoration,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                spacing: 8,
                                children: [
                                  Tooltip(
                                    waitDuration: Duration(milliseconds: 100),
                                    message: mostPopularSchedule?.movie.title,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration:
                                          style.accentCardDecoration.copyWith(
                                        color: Colors.transparent,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        width: 100,
                                        fit: BoxFit.cover,
                                        imageUrl: mostPopularSchedule
                                                ?.movie.posterUrl ??
                                            "",
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: style.accentCardDecoration,
                                    child: Center(
                                      child: Text(
                                        "$mostPopularScheduleTicketCount",
                                        style: style.displayLarge,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            Container(
              decoration: style.cardDecoration,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                spacing: 12,
                children: [
                  countBox("Filmas", movieCount),
                  countBox("Lietotāji", userCount),
                  countBox("Piedavājumi", offerCount),
                  countBox("Promokodi", promoCodeCount),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container schedule() {
    return Container(
      width: 655,
      decoration: style.cardDecoration,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Column(
        spacing: 25,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Šodienas saraksts:",
                    style: style.headlineMedium,
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM y', 'lv').format(DateTime.now()),
                    style: style.headlineSmall,
                  ),
                ],
              ),
              Container(
                width: 55,
                decoration: style.accentCardDecoration,
                child: Center(
                  child: Text(
                    "${scheduleItems.length}",
                    style: style.displayLarge,
                  ),
                ),
              ),
            ],
          ),
          if (scheduleItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(
                "Šodienas saraksts ir tukšs",
                style: style.bodyLarge,
              ),
            ),
          if (scheduleItems.isNotEmpty)
            SizedBox(
              width: 650,
              height: 250,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 20,
                  childAspectRatio: 2,
                  mainAxisExtent: 55,
                ),
                itemCount: scheduleItems.length,
                itemBuilder: (context, index) => generateScheduleWidget(index),
              ),
            ),
        ],
      ),
    );
  }

  countBox(String title, int count) {
    return Container(
      width: 160,
      height: 108,
      decoration: style.roundCardDecoration,
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: style.headlineMedium,
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: style.accentCardDecoration,
            child: Center(
              child: Text(
                "$count",
                style: style.displayLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ScheduleCard generateScheduleWidget(int index) {
    return ScheduleCard(
      data: scheduleItems[index],
      onEdit: (id) {},
      small: true,
    );
  }
}
