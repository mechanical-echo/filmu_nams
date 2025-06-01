import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/dashboard_controller.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/models/payment_history_model.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/edit_schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_schedule/schedule_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DashboardController _dashboardController = DashboardController();

  StreamSubscription<QuerySnapshot>? _scheduleSubscription;
  StreamSubscription<QuerySnapshot>? _paymentsSubscription;
  StreamSubscription<QuerySnapshot>? _upcomingMoviesSubscription;

  Style get style => Style.of(context);

  List<ScheduleModel> todaySchedule = [];
  List<PaymentHistoryModel> recentPayments = [];
  List<MovieModel> upcomingMovies = [];
  ScheduleModel? mostPopularSchedule;
  int mostPopularScheduleTicketCount = 0;
  String? currentAdminName;

  int movieCount = 0;
  int userCount = 0;
  int offerCount = 0;
  int promoCodeCount = 0;
  double todayRevenue = 0;
  int todayTicketCount = 0;

  bool isLoading = true;
  bool isLoadingRevenue = true;
  bool isLoadingUpcoming = true;

  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    _loadCurrentAdminName();
    _listenToTodaySchedule();
    _listenToRecentPayments();
    _listenToUpcomingMovies();
    _getMostPopularSchedule();
    _fetchStats();
    _calculateTodayRevenue();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scheduleSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _upcomingMoviesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentAdminName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            currentAdminName = docSnapshot.data()?['name'] ?? 'Administrator';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading admin name: $e');
    }
  }

  void _listenToTodaySchedule() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    _scheduleSubscription = _firestore
        .collection('schedule')
        .where('time', isGreaterThanOrEqualTo: startTimestamp)
        .where('time', isLessThanOrEqualTo: endTimestamp)
        .orderBy('time', descending: false)
        .limit(5)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        todaySchedule = items;
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to schedule changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  void _listenToRecentPayments() {
    _paymentsSubscription = _firestore
        .collection('payments')
        .orderBy('purchaseDate', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => PaymentHistoryModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        recentPayments = items;
      });
    }, onError: (e) {
      debugPrint('Error listening to payment changes: $e');
    });
  }

  void _listenToUpcomingMovies() {
    final now = DateTime.now();
    final nowTimestamp = Timestamp.fromDate(now);

    _upcomingMoviesSubscription = _firestore
        .collection('movies')
        .where('premiere', isGreaterThan: nowTimestamp)
        .orderBy('premiere', descending: false)
        .limit(3)
        .snapshots()
        .listen((snapshot) async {
      final items = snapshot.docs
          .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        upcomingMovies = items;
        isLoadingUpcoming = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to upcoming movies: $e');
      setState(() {
        isLoadingUpcoming = false;
      });
    });
  }

  void _getMostPopularSchedule() {
    _dashboardController.getMostPopularSchedule().then((result) {
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

  void _fetchStats() {
    _dashboardController.getCounts().then((result) {
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

  void _calculateTodayRevenue() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    _firestore
        .collection('payments')
        .where('purchaseDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('purchaseDate', isLessThanOrEqualTo: endTimestamp)
        .where('status', isEqualTo: 'completed')
        .get()
        .then((snapshot) {
      double revenue = 0;
      int ticketCount = 0;

      for (var doc in snapshot.docs) {
        revenue += (doc.data()['amount'] as num).toDouble();

        if (doc.data()['tickets'] != null) {
          ticketCount += (doc.data()['tickets'] as List).length;
        }
      }

      setState(() {
        todayRevenue = revenue;
        todayTicketCount = ticketCount;
        isLoadingRevenue = false;
      });
    }).catchError((error) {
      debugPrint('Error calculating today revenue: $error');
      setState(() {
        isLoadingRevenue = false;
      });
    });
  }

  void _openScheduleDialog({String? id, DateTime? dateTime}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditScheduleDialog(id: id, dateTime: dateTime);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _openMovieDialog(MovieModel movie) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditMovieDialog(data: movie);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 41,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _buildWelcomeSection(),
            _buildStatisticsSection(),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Expanded(flex: 3, child: _buildTodayScheduleSection()),
                  Expanded(flex: 2, child: _buildUpcomingMoviesSection()),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Expanded(child: _buildRecentPaymentsSection()),
                  Expanded(child: _buildPopularMovieSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = _currentTime;
    String greeting;

    if (now.hour < 12) {
      greeting = "Labrīt";
    } else if (now.hour < 18) {
      greeting = "Labdien";
    } else {
      greeting = "Labvakar";
    }

    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting, ${currentAdminName ?? 'Administrators'}!",
                    style: style.displayLarge,
                  ),
                  Text(
                    format(now),
                    style: style.headlineMedium.copyWith(
                      color: style.contrast.withAlpha(178),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: style.accentCardDecoration,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white70,
                    ),
                    Text(
                      DateFormat('HH:mm:ss').format(now),
                      style: style.headlineLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1075) {
          return Row(
            spacing: 8,
            children: List.generate(
              _buildStatCards().length,
              (index) => index < _buildStatCards().length - 2
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
    );
  }

  _buildStatCards() {
    return [
      _buildStatCard(
        title: "Filmas",
        value: "$movieCount",
        icon: Icons.movie,
        color: Colors.blue,
      ),
      _buildStatCard(
        title: "Lietotāji",
        value: "$userCount",
        icon: Icons.people,
        color: Colors.green,
      ),
      _buildStatCard(
        title: "Piedāvājumi",
        value: "$offerCount",
        icon: Icons.local_offer,
        color: Colors.orange,
      ),
      _buildStatCard(
        title: "Promokodi",
        value: "$promoCodeCount",
        icon: Icons.confirmation_number,
        color: Colors.purple,
      ),
      _buildStatCard(
        title: "Šodienas ieņēmumi",
        value: isLoadingRevenue ? "-" : "${todayRevenue.toStringAsFixed(2)}€",
        icon: Icons.euro,
        color: style.primary,
        isLoading: isLoadingRevenue,
      ),
      _buildStatCard(
        title: "Šodienas biļetes",
        value: isLoadingRevenue ? "-" : "$todayTicketCount",
        icon: Icons.confirmation_number,
        color: style.primary,
        isLoading: isLoadingRevenue,
      )
    ];
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return IntrinsicWidth(
      child: Container(
        decoration: style.cardDecoration,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: style.titleMedium.copyWith(
                    color: style.contrast.withAlpha(178),
                  ),
                ),
                isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: style.contrast,
                          size: 20,
                        ),
                      )
                    : Text(
                        value,
                        style: style.headlineMedium,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayScheduleSection() {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Šodienas saraksts",
                style: style.headlineMedium,
              ),
              TextButton.icon(
                onPressed: () => _openScheduleDialog(dateTime: DateTime.now()),
                icon: Icon(Icons.add),
                label: Text("Pievienot"),
                style: TextButton.styleFrom(
                  foregroundColor: style.primary,
                ),
              ),
            ],
          ),
          Text(
            format(DateTime.now()),
            style: style.titleMedium.copyWith(
              color: style.contrast.withAlpha(178),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: style.contrast.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: style.contrast,
                      size: 40,
                    ),
                  )
                : todaySchedule.isEmpty
                    ? Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: style.contrast.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Šodienas saraksts ir tukšs",
                            style: style.bodyLarge,
                          ),
                        ),
                      )
                    : Column(
                        spacing: 8,
                        children: todaySchedule
                            .map(
                              (schedule) => ScheduleCard(
                                data: schedule,
                                onEdit: (id) => _openScheduleDialog(id: id),
                                small: true,
                              ),
                            )
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularMovieSection() {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Populārākā filma",
            style: style.headlineMedium,
          ),
          Text(
            "Visvairāk pārdoto biļešu",
            style: style.titleMedium.copyWith(
              color: style.contrast.withAlpha(178),
            ),
          ),
          const SizedBox(height: 16),
          mostPopularSchedule == null
              ? Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: style.contrast.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Nav pieejamu datu",
                      style: style.bodyLarge,
                    ),
                  ),
                )
              : Column(
                  spacing: 16,
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: mostPopularSchedule!.movie.heroUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: style.contrast,
                            size: 40,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Text(
                      mostPopularSchedule!.movie.title,
                      style: style.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.local_activity,
                          color: style.primary,
                          size: 20,
                        ),
                        Text(
                          "$mostPopularScheduleTicketCount biļetes",
                          style: style.titleMedium.copyWith(
                            color: style.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: style.contrast.withAlpha(178),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(
                            mostPopularSchedule!.time.toDate(),
                          ),
                          style: style.bodyMedium.copyWith(
                            color: style.contrast.withAlpha(178),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.meeting_room,
                          size: 16,
                          color: style.contrast.withAlpha(178),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Zāle ${mostPopularSchedule!.hall}",
                          style: style.bodyMedium.copyWith(
                            color: style.contrast.withAlpha(178),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _openMovieDialog(mostPopularSchedule!.movie),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: style.primary,
                        foregroundColor: style.onPrimary,
                        minimumSize: Size(double.infinity, 40),
                      ),
                      child: Text("Filmas informācija"),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentsSection() {
    return Container(
      width: 500,
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            "Pēdējie maksājumi",
            style: style.headlineMedium,
          ),
          recentPayments.isEmpty
              ? Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: style.contrast.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Nav pieejamu maksājumu",
                      style: style.bodyLarge,
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: style.contrast.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    spacing: 8,
                    children: recentPayments.map((payment) {
                      final isCompleted = payment.status == 'completed';
                      return Container(
                        decoration: style.cardDecoration,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          spacing: 12,
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    payment.product,
                                    style: style.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('dd.MM.yyyy HH:mm').format(
                                      payment.purchaseDate.toDate(),
                                    ),
                                    style: style.bodySmall.copyWith(
                                      color: style.contrast.withAlpha(178),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 4,
                              children: [
                                Text(
                                  "${payment.amount.toStringAsFixed(2)}€",
                                  style: style.titleMedium.copyWith(
                                    color: isCompleted
                                        ? style.contrast
                                        : Colors.red,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.withAlpha(50)
                                        : Colors.red.withAlpha(50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    PaymentHistoryStatusEnum.getStatus(
                                        payment.status),
                                    style: style.bodySmall.copyWith(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMoviesSection() {
    return Container(
      decoration: style.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Drīzumā",
                style: style.headlineMedium,
              ),
            ],
          ),
          isLoadingUpcoming
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: style.contrast,
                    size: 40,
                  ),
                )
              : upcomingMovies.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: style.contrast.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Nav gaidāmu filmu",
                          style: style.bodyLarge,
                        ),
                      ),
                    )
                  : Column(
                      spacing: 16,
                      children: upcomingMovies.map((movie) {
                        return GestureDetector(
                          onTap: () => _openMovieDialog(movie),
                          child: Container(
                            decoration: BoxDecoration(
                              color: style.contrast.withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: style.contrast.withAlpha(25),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              spacing: 12,
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(
                                    imageUrl: movie.posterUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: LoadingAnimationWidget
                                          .staggeredDotsWave(
                                        color: style.contrast,
                                        size: 20,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: style.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        movie.genre,
                                        style: style.bodySmall.copyWith(
                                          color: style.contrast.withAlpha(178),
                                        ),
                                      ),
                                      Row(
                                        spacing: 8,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: style.primary,
                                          ),
                                          Text(
                                            DateFormat('dd.MM.yyyy').format(
                                              movie.premiere.toDate(),
                                            ),
                                            style: style.bodySmall.copyWith(
                                              color: style.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  String format(DateTime date) {
    final formatedDate = DateFormat('EEEE, d MMMM y', 'lv').format(date);
    return formatedDate.substring(0, 1).toUpperCase() +
        formatedDate.substring(1);
  }
}
