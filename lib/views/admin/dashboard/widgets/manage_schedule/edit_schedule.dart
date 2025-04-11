import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditSchedule extends StatefulWidget {
  const EditSchedule({
    super.key,
    required this.id,
    required this.action,
  });

  final String id;
  final Function(String) action;

  @override
  State<EditSchedule> createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MovieController _movieController = MovieController();

  ScheduleModel? scheduleData;
  List<MovieModel> allMovies = [];
  bool isLoading = true;
  bool isUpdating = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int selectedHall = 1;
  String? selectedMovieId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<MovieModel> movies = await _movieController.getAllMovies();
      ScheduleModel? schedule;

      if (widget.id.isNotEmpty) {
        final documentSnapshot =
            await _firestore.collection('schedule').doc(widget.id).get();
        if (documentSnapshot.exists) {
          schedule = await ScheduleModel.fromMapAsync(
            documentSnapshot.data() as Map<String, dynamic>,
            documentSnapshot.id,
          );

          final scheduleDateTime = schedule.time.toDate();

          setState(() {
            selectedDate = scheduleDateTime;
            selectedTime = TimeOfDay(
              hour: scheduleDateTime.hour,
              minute: scheduleDateTime.minute,
            );
            selectedHall = schedule!.hall;
            selectedMovieId = schedule.movie.id;
          });
        }
      }

      setState(() {
        allMovies = movies;
        scheduleData = schedule;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās ielādēt datus",
        );
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (selectedMovieId == null) {
      StylizedDialog.dialog(Icons.error_outline,
        context,
        "Kļūda",
        "Lūdzu, izvēlieties filmu",
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final DateTime scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final DocumentReference movieRef =
          _firestore.collection('movies').doc(selectedMovieId);

      final Map<String, dynamic> scheduleData = {
        'movie': movieRef,
        'hall': selectedHall,
        'time': Timestamp.fromDate(scheduledDateTime),
      };

      if (widget.id.isEmpty) {
        await _firestore.collection('schedule').add(scheduleData);
      } else {
        await _firestore
            .collection('schedule')
            .doc(widget.id)
            .update(scheduleData);
      }

      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Veiksmīgi",
          widget.id.isEmpty ? "Saraksts pievienots" : "Saraksts atjaunināts",
        );
        widget.action("mng_schedule");
      }
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt sarakstu",
        );
      }
    }

    setState(() {
      isUpdating = false;
    });
  }

  Future<void> _deleteSchedule() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst sarakstu?", style: header2),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo sarakstu? Šo darbību nevar atsaukt.",
                  style: bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Atcelt"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    child: const Text("Dzēst"),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        setState(() {
          isUpdating = true;
        });

        await _firestore.collection('schedule').doc(widget.id).delete();

        if (mounted) {
          widget.action("mng_schedule");
        }
      }
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās dzēst sarakstu",
        );
      }
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: red002,
              onPrimary: Colors.white,
              surface: red001,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color.fromARGB(255, 44, 39, 39),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: red002,
              onPrimary: Colors.white,
              surface: red001,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color.fromARGB(255, 44, 39, 39),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 800,
        maxHeight: 800,
      ),
      decoration: classicDecorationDark,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: isLoading || isUpdating ? _buildLoading() : _buildFormContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: smokeyWhite,
        size: 100,
      ),
    );
  }

  Widget _buildFormContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
      decoration: classicDecorationSharp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateTimePickers(),
                  const SizedBox(height: 20),
                  _buildHallSelector(),
                  const SizedBox(height: 20),
                  _buildMovieSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: classicDecorationWhiteSharper,
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 5,
          ),
          child: Text(
            widget.id.isEmpty ? "Jauns saraksts" : "Rediģēt sarakstu",
            style: header2Red,
          ),
        ),
        StylizedButton(
          action: () => widget.action("mng_schedule"),
          title: "Atpakaļ",
          icon: Icons.chevron_left_rounded,
          textStyle: header2Red,
          iconSize: 35,
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(Icons.calendar_today, size: 25, color: smokeyWhite),
            Text('Datums un laiks', style: bodyLarge),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: classicDecorationSharper,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(selectedDate),
                        style: bodyMedium,
                      ),
                      Icon(Icons.edit_calendar, color: smokeyWhite),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: classicDecorationSharper,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime.format(context),
                        style: bodyMedium,
                      ),
                      Icon(Icons.access_time, color: smokeyWhite),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHallSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(Icons.meeting_room, size: 25, color: smokeyWhite),
            Text('Zāle', style: bodyLarge),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          decoration: classicDecorationSharper,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedHall,
              isExpanded: true,
              dropdownColor: red001,
              style: bodyMedium,
              icon: Icon(Icons.arrow_drop_down, color: smokeyWhite),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedHall = newValue;
                  });
                }
              },
              items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('Zāle $value'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(Icons.movie, size: 25, color: smokeyWhite),
            Text('Filma', style: bodyLarge),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          decoration: classicDecorationSharper,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMovieId,
              isExpanded: true,
              dropdownColor: red001,
              style: bodyMedium,
              icon: Icon(Icons.arrow_drop_down, color: smokeyWhite),
              hint: Text('Izvēlieties filmu', style: bodyMedium),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMovieId = newValue;
                  });
                }
              },
              items:
                  allMovies.map<DropdownMenuItem<String>>((MovieModel movie) {
                return DropdownMenuItem<String>(
                  value: movie.id,
                  child: Text(movie.title),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StylizedButton(
          action: _saveSchedule,
          title: widget.id.isEmpty ? "Pievienot sarakstu" : "Saglabāt izmaiņas",
          icon: widget.id.isEmpty ? Icons.add : Icons.save,
        ),
        if (widget.id.isNotEmpty)
          StylizedButton(
            action: _deleteSchedule,
            title: "Dzēst sarakstu",
            icon: Icons.delete_forever,
          ),
      ],
    );
  }
}
