import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditScheduleDialog extends StatefulWidget {
  const EditScheduleDialog({
    super.key,
    this.id,
    this.dateTime,
  });

  final String? id;
  final DateTime? dateTime;

  @override
  State<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<EditScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MovieController _movieController = MovieController();

  Style get theme => Style.of(context);

  List<MovieModel> movies = [];
  ScheduleModel? scheduleData;
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
      final List<MovieModel> loadedMovies =
          await _movieController.getAllMovies();
      ScheduleModel? schedule;

      if (widget.id != null) {
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
        if (widget.dateTime != null) {
          selectedDate = widget.dateTime!;
          selectedTime = TimeOfDay(
            hour: widget.dateTime!.hour,
            minute: widget.dateTime!.minute,
          );
        }
        movies = loadedMovies;
        scheduleData = schedule;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās ielādēt datus",
        );
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedMovieId == null) {
      StylizedDialog.dialog(
        Icons.error_outline,
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

      if (widget.id == null) {
        await _firestore.collection('schedule').add(scheduleData);
        if (mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Saraksts pievienots",
          );
        }
      } else {
        await _firestore
            .collection('schedule')
            .doc(widget.id)
            .update(scheduleData);
        if (mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Saraksts atjaunināts",
          );
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
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
                title: Text("Dzēst sarakstu?", style: theme.headlineMedium),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo sarakstu? Šo darbību nevar atsaukt.",
                  style: theme.bodyMedium,
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
          Navigator.of(context).pop();
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Saraksts dzēsts",
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
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
              primary: theme.primary,
              onPrimary: theme.onPrimary,
              surface: theme.surface,
              onSurface: theme.onSurface,
            ),
            dialogBackgroundColor: theme.surface,
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
              primary: theme.primary,
              onPrimary: theme.onPrimary,
              surface: theme.surface,
              onSurface: theme.onSurface,
            ),
            dialogBackgroundColor: theme.surface,
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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: isLoading || isUpdating
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.contrast,
                    size: 80,
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildFormContent(),
                        const SizedBox(height: 40),
                        _buildButtonRow(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.id == null ? "Jauns saraksts" : "Rediģēt sarakstu",
          style: theme.displayMedium,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datums un laiks', style: theme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(selectedDate),
                        style: theme.bodyLarge,
                      ),
                      Icon(Icons.calendar_today, color: theme.primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime.format(context),
                        style: theme.bodyLarge,
                      ),
                      Icon(Icons.access_time, color: theme.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Zāle', style: theme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.surfaceVariant.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedHall,
              isExpanded: true,
              dropdownColor: theme.surface,
              style: theme.bodyLarge,
              icon: Icon(Icons.arrow_drop_down, color: theme.primary),
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
        const SizedBox(height: 24),
        Text('Filma', style: theme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.surfaceVariant.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMovieId,
              isExpanded: true,
              dropdownColor: theme.surface,
              style: theme.bodyLarge,
              icon: Icon(Icons.arrow_drop_down, color: theme.primary),
              hint: Text('Izvēlieties filmu',
                  style: theme.bodyLarge
                      .copyWith(color: theme.contrast.withOpacity(0.5))),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMovieId = newValue;
                  });
                }
              },
              items: movies.map<DropdownMenuItem<String>>((MovieModel movie) {
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.id != null)
          TextButton(
            onPressed: _deleteSchedule,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: Text("Dzēst"),
          ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Atcelt"),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: _saveSchedule,
          child: Text(widget.id == null ? "Pievienot" : "Saglabāt"),
        ),
      ],
    );
  }
}
