import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({super.key});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  ScheduleModel? scheduleData;
  List<MovieModel> movieData = [];
  bool isLoading = true;

  Future<void> fetchSchedule() async {
    final currentDate = DateTime.now();

    try {
      final response = await MovieController().getSchedule(currentDate);
      setState(() {
        scheduleData = response;
      });

      for (var scheduleItem in response.movies) {
        try {
          if (scheduleItem.movie == null) {
            debugPrint('Skipping schedule item with null movieId');
            continue;
          }

          final movieDetails =
              await MovieController().getMovieById(scheduleItem.movie!.id);

          setState(() {
            movieData.add(movieDetails);
          });
        } catch (e, stackTrace) {
          debugPrint('Error fetching movie details: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching schedule: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 100)
          : Column(
              children: List.generate(
                movieData.length,
                (index) => Text(movieData[index].title),
              ),
            ),
    );
  }
}

class ScheduleMovieItem extends StatelessWidget {
  const ScheduleMovieItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
