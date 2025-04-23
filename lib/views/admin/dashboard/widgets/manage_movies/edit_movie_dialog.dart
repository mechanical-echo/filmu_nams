import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/offer_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/search_movie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../controllers/movie_controller.dart';
import '../../../../../providers/color_context.dart';

class EditMovieDialog extends StatefulWidget {
  const EditMovieDialog({
    super.key,
    this.data,
  });

  final MovieModel? data;

  @override
  State<EditMovieDialog> createState() => _EditMovieDialogState();
}

class _EditMovieDialogState extends State<EditMovieDialog> {
  final _formKey = GlobalKey<FormState>();

  ContextTheme get theme => ContextTheme.of(context);

  MovieController movieController = MovieController();
  OfferController offerController = OfferController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController actorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController directorController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController ratingController = TextEditingController();

  String? selectedMovieId;
  String? selectedOfferId;

  bool isLoading = false;

  Uint8List? posterImage;
  Uint8List? heroImage;

  String? title() => titleController.text;

  List<dynamic> actors = [];

  @override
  void initState() {
    super.initState();

    titleController.text = widget.data?.title ?? "";
    descriptionController.text = widget.data?.description ?? "";
    genreController.text = widget.data?.genre ?? "";
    directorController.text = widget.data?.director ?? "";
    dateController.text = widget.data?.premiere.toDate().toString() ?? "";
    durationController.text = widget.data?.duration.toString() ?? "";
    ratingController.text = widget.data?.rating ?? "";

    actors = widget.data?.actors ?? [];

    titleController.addListener(() {
      setState(() {});
    });

    dateController.addListener(() {
      setState(() {});
    });

    durationController.addListener(() {
      setState(() {});
    });
  }

  void resetFields() {
    titleController.dispose();
    descriptionController.dispose();
    actorController.dispose();
    genreController.dispose();
    directorController.dispose();
    dateController.dispose();
    durationController.dispose();
    ratingController.dispose();
    actors.clear();
    posterImage = null;
    heroImage = null;
  }

  Future<void> pickImage(bool isPoster) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        isPoster
            ? setState(() => posterImage = bytes)
            : setState(() => heroImage = bytes);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdēvas pievienot bildi: ${e.toString()}",
        );
      }
    }
  }

  void addActor() {
    if (actorController.text.isNotEmpty) {
      setState(() {
        actors.add(actorController.text);
        actorController.clear();
      });
    } else {
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Lūdzu ievadiet aktiera vārdu.",
      );
    }
  }

  void removeActor(int index) {
    setState(() {
      actors.removeAt(index);
    });
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      if (actors.isEmpty) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Lūdzu pievienojiet vismaz vienu aktieri.",
        );
        return;
      }

      if (widget.data == null && posterImage == null) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Lūdzu pievienojiet plakāta attēlu.",
        );
        return;
      }

      if (widget.data == null && heroImage == null) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Lūdzu pievienojiet vāka attēlu.",
        );
        return;
      }

      if (widget.data == null || widget.data!.id == 'new') {
        add();
      } else {
        edit();
      }
    }
  }

  void delete() {
    StylizedDialog.dialog(
      Icons.warning_amber_outlined,
      context,
      "Brīdinājums",
      "Vai tiešām vēlaties izdzēst šo elementu?",
      onConfirm: () => deleteItem(),
    );
  }

  void search() {
    Navigator.of(context).pop();
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SearchMovie();
      },
    );
  }

  void deleteItem() {
    setState(() {
      isLoading = true;
    });
    movieController.deleteMovie(widget.data!.id).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        StylizedDialog.dialog(
          Icons.check_circle_outline,
          context,
          "Veiksmīgi",
          "Elements veiksmīgi izdzēsts.",
        );
      }
    }).catchError((error) {
      if (mounted) {
        Navigator.of(context).pop();
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdēvas izdzēst elementu: ${error.toString()}",
        );
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void add() {
    setState(() {
      isLoading = true;
    });

    String? heroUrl;
    String? posterUrl;

    if (widget.data!.id == 'new') {
      posterUrl = widget.data?.posterUrl;
      heroUrl = widget.data?.heroUrl;
    }

    movieController
        .addMovie(
      title: title(),
      description: descriptionController.text,
      genre: genreController.text,
      director: directorController.text,
      premiere: Timestamp.fromDate(DateTime.parse(dateController.text)),
      duration: int.parse(durationController.text),
      rating: ratingController.text,
      actors: actors,
      posterImage: posterImage,
      heroImage: heroImage,
      poster: posterUrl,
      hero: heroUrl,
    )
        .then((response) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdēvas rediget filmu: ${error.toString()}",
        );
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void createCarouselItem() {
    final carouselItem = CarouselItemModel.fromMap({
      'title': '',
      'image-url': widget.data!.posterUrl,
      'description': '',
      'movie': widget.data!,
      'offer': null,
    }, 'new');

    debugPrint(
      'Creating carousel item with movie: ${widget.data != null}',
    );

    Navigator.of(context).pop();

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditCarouselItemDialog(data: carouselItem);
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

  void edit() {
    movieController
        .updateMovie(
      movie: widget.data!,
      title: title()!,
      description: descriptionController.text,
      genre: genreController.text,
      director: directorController.text,
      premiere: Timestamp.fromDate(DateTime.parse(dateController.text)),
      duration: int.parse(durationController.text),
      rating: ratingController.text,
      actors: actors,
      posterImage: posterImage,
      heroImage: heroImage,
    )
        .then((_) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdēvas rediget filmu: ${error.toString()}",
        );
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  String calculateTime() {
    return durationController.text.isNotEmpty
        ? "${(int.parse(durationController.text) / 60).floor()}h ${int.parse(durationController.text) % 60}min"
        : "0h 00min";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1020,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 80,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(50),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 50,
                          children: [
                            SingleChildScrollView(
                              child: imageColumn(),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    spacing: 25,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        spacing: 10,
                                        children: [
                                          Text(
                                            widget.data == null ||
                                                    widget.data!.id == 'new'
                                                ? "Pievienot:"
                                                : "Rediģēt:",
                                            style: theme.headlineMedium
                                                .copyWith(
                                                    color: Colors.white
                                                        .withAlpha(180)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              titleController.text,
                                              style: theme.displayLarge,
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextFormField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Nosaukums',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lūdzu ievadiet nosaukumu';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: descriptionController,
                                        minLines: 5,
                                        maxLines: 5,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Apraksts',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lūdzu ievadiet aprakstu';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: ratingController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Vecuma ierobežojums',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lūdzu ievadiet vecuma ierobežojumu';
                                          }
                                          return null;
                                        },
                                      ),
                                      horizontalDivider(),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: genreController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Žanrs',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Lūdzu ievadiet žanru';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: directorController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Režisors',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Lūdzu ievadiet režisoru';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          Expanded(
                                            child: datepicker(context),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: durationController,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Ilgums (min)',
                                                suffix: Text(
                                                    "~ ${calculateTime()}"),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Lūdzu ievadiet ilgumu';
                                                }
                                                try {
                                                  int duration =
                                                      int.parse(value);
                                                  if (duration <= 0) {
                                                    return 'Ilgumam jābūt lielākam par 0';
                                                  }
                                                } catch (e) {
                                                  return 'Ievadiet derīgu skaitli';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      horizontalDivider(),
                                      Row(
                                        spacing: 10,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: actorController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Pievienot aktieri',
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: addActor,
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                              color: theme.contrast,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actors.isNotEmpty
                                          ? Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: List.generate(
                                                actors.length,
                                                (index) => Chip(
                                                  label: Text(actors[index]),
                                                  deleteIcon: Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                  onDeleted: () =>
                                                      removeActor(index),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: Text(
                                                "Pievienojiet vismaz vienu aktieri",
                                                style: TextStyle(
                                                  color: actors.isEmpty &&
                                                          _formKey.currentState
                                                                  ?.validate() ==
                                                              false
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 50,
                        right: 50,
                        bottom: 25,
                      ),
                      child: Center(
                        child: Wrap(
                          spacing: 25,
                          runSpacing: 15,
                          runAlignment: WrapAlignment.center,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                              ),
                              child: Text("Atcelt"),
                            ),
                            if (widget.data != null && widget.data!.id != 'new')
                              FilledButton(
                                onPressed: delete,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                ),
                                child: Text("Dzēst"),
                              ),
                            FilledButton(
                              onPressed: submit,
                              child: Text("Saglabāt"),
                            ),
                            if (widget.data == null || widget.data!.id == 'new')
                              FilledButton(
                                onPressed: search,
                                child: Text("Meklēt, lai pievienot"),
                              ),
                            if (widget.data != null && widget.data!.id != 'new')
                              FilledButton(
                                onPressed: createCarouselItem,
                                child: Text("Uztaisīt sākuma elementu"),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget datepicker(BuildContext context) {
    return InkWell(
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        ).then((value) {
          if (value != null) {
            setState(() {
              dateController.text = value.toIso8601String();
            });
          }
        });
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: dateController.text.isNotEmpty
                ? DateFormat('dd. MMMM, y.', 'lv').format(
                    DateTime.parse(
                      dateController.text,
                    ),
                  )
                : '',
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Izlaiduma datums',
          ),
          validator: (value) {
            if (dateController.text.isEmpty) {
              return 'Lūdzu izvēlieties datumu';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget horizontalDivider() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
      ),
    );
  }

  Column imageColumn() {
    return Column(
      spacing: 25,
      children: [
        SizedBox(
          width: 290,
          child: posterImage != null
              ? Image.memory(posterImage!)
              : widget.data?.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.data!.posterUrl,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 290,
                      height: 390,
                      color: Colors.grey[800],
                      child: Center(
                        child: Text(
                          "Nav pievienota bilde",
                          style: theme.bodyMedium,
                        ),
                      ),
                    ),
        ),
        FilledButton(
          onPressed: () => pickImage(true),
          child: Text("Mainīt bildi"),
        ),
        coverImage(),
      ],
    );
  }

  Widget coverImage() {
    return Column(
      spacing: 25,
      children: [
        SizedBox(
          width: 290,
          child: heroImage != null
              ? Image.memory(heroImage!)
              : widget.data?.heroUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.data!.heroUrl,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 290,
                      height: 390,
                      color: Colors.grey[800],
                      child: Center(
                        child: Text(
                          "Nav pievienota bilde",
                          style: theme.bodyMedium,
                        ),
                      ),
                    ),
        ),
        FilledButton(
          onPressed: () => pickImage(false),
          child: Text("Mainīt bildi"),
        ),
      ],
    );
  }
}
