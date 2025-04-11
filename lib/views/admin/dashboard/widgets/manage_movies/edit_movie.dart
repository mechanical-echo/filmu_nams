import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item.dart/form_input.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditMovie extends StatefulWidget {
  const EditMovie({
    super.key,
    required this.id,
    required this.action,
  });

  final String id;
  final Function(String) action;

  @override
  State<EditMovie> createState() => _EditMovieState();
}

class _EditMovieState extends State<EditMovie> {
  final MovieController _movieController = MovieController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController directorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController actorsController = TextEditingController();

  MovieModel? movieData;
  Uint8List? posterImage;
  Uint8List? heroImage;
  bool isLoading = true;
  bool isPosterImageSelected = false;
  bool isHeroImageSelected = false;

  Future<void> fetchMovieData() async {
    try {
      movieData = await _movieController.getMovieById(widget.id);
      setState(() {
        titleController.text = movieData!.title;
        descriptionController.text = movieData!.description;
        directorController.text = movieData!.director;
        genreController.text = movieData!.genre;
        ratingController.text = movieData!.rating;
        durationController.text = movieData!.duration.toString();
        actorsController.text = movieData!.actors.join(', ');
      });
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,context, "Kļūda", 'Neizdevās iegūt filmas datus');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateMovie() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<String> actorsList = actorsController.text
          .split(',')
          .map((actor) => actor.trim())
          .where((actor) => actor.isNotEmpty)
          .toList();

      int duration = int.tryParse(durationController.text) ?? 0;

      await _movieController.updateMovie(
        widget.id,
        titleController.text,
        descriptionController.text,
        directorController.text,
        genreController.text,
        ratingController.text,
        duration,
        actorsList,
        posterImage,
        heroImage,
        isPosterImageSelected ? null : movieData!.posterUrl,
        isHeroImageSelected ? null : movieData!.heroUrl,
      );

      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,context, "Veiksmīgi", "Filma ir atjaunināta");
      }
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,context, "Kļūda", "Neizdevās atjaunināt filmu");
      }
    }

    setState(() {
      isLoading = false;
      isPosterImageSelected = false;
      isHeroImageSelected = false;
    });

    fetchMovieData();
  }

  Future<void> deleteMovie() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst filmu?", style: header2),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo filmu? Šo darbību nevar atsaukt.",
                  style: bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Atcelt"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[700]),
                    child: Text("Dzēst"),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        setState(() {
          isLoading = true;
        });

        await _movieController.deleteMovie(widget.id);

        if (mounted) {
          widget.action("mng_movies");
        }
      }
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,context, "Kļūda", "Neizdevās dzēst filmu");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickPosterImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        posterImage = imageBytes;
        isPosterImageSelected = true;
      });
    }
  }

  Future<void> _pickHeroImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        heroImage = imageBytes;
        isHeroImageSelected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMovieData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 1300,
        maxHeight: 800,
      ),
      decoration: classicDecorationDark,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: isLoading || movieData == null
          ? loading()
          : SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      imagesColumn(),
                      Expanded(
                        child: detailsColumn(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget header() {
    return Container(
      decoration: classicDecorationSharp,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      child: Row(
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
              movieData!.title,
              style: header2Red,
            ),
          ),
          StylizedButton(
            action: () => widget.action("mng_movies"),
            title: "Atpakaļ",
            icon: Icons.chevron_left_rounded,
            textStyle: header2Red,
            iconSize: 35,
          ),
        ],
      ),
    );
  }

  Widget detailsColumn() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 35,
      ),
      decoration: classicDecorationSharp,
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormInput(
            icon: Icons.title,
            title: 'Nosaukums',
            controller: titleController,
            heightLines: 1,
          ),
          SizedBox(height: 15),
          FormInput(
            icon: Icons.description,
            title: 'Apraksts',
            controller: descriptionController,
            heightLines: 5,
          ),
          SizedBox(height: 15),
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: FormInput(
                  icon: Icons.movie_filter,
                  title: 'Žanrs',
                  controller: genreController,
                  heightLines: 1,
                ),
              ),
              Expanded(
                child: FormInput(
                  icon: Icons.timer,
                  title: 'Ilgums (minūtes)',
                  controller: durationController,
                  heightLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: FormInput(
                  icon: Icons.person,
                  title: 'Režisors',
                  controller: directorController,
                  heightLines: 1,
                ),
              ),
              Expanded(
                child: FormInput(
                  icon: Icons.star,
                  title: 'Reitings',
                  controller: ratingController,
                  heightLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          FormInput(
            icon: Icons.people,
            title: 'Aktieri (atdalīti ar komatu)',
            controller: actorsController,
            heightLines: 2,
          ),
          SizedBox(height: 30),
          buttonRow(),
        ],
      ),
    );
  }

  Widget buttonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StylizedButton(
          action: updateMovie,
          title: "Saglabāt izmaiņas",
          icon: Icons.save,
        ),
        StylizedButton(
          action: deleteMovie,
          title: "Dzēst filmu",
          icon: Icons.delete_forever,
        ),
      ],
    );
  }

  Widget imagesColumn() {
    return Container(
      width: 350,
      decoration: classicDecorationSharp,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Plakāts', style: header2),
          SizedBox(height: 10),
          Container(
            width: 200,
            height: 300,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: cardShadow,
            ),
            child: isPosterImageSelected && posterImage != null
                ? Image.memory(posterImage!, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: movieData!.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
          ),
          SizedBox(height: 10),
          StylizedButton(
            action: _pickPosterImage,
            title: "Mainīt plakātu",
            icon: Icons.image,
          ),
          SizedBox(height: 20),
          Text('Fona attēls', style: header2),
          SizedBox(height: 10),
          Container(
            width: 300,
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: cardShadow,
            ),
            child: isHeroImageSelected && heroImage != null
                ? Image.memory(heroImage!, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: movieData!.heroUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
          ),
          SizedBox(height: 10),
          StylizedButton(
            action: _pickHeroImage,
            title: "Mainīt fona attēlu",
            icon: Icons.image,
          ),
        ],
      ),
    );
  }

  Center loading() {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: smokeyWhite,
        size: 100,
      ),
    );
  }
}
