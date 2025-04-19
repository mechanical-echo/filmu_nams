import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/offer_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../controllers/movie_controller.dart';
import '../../../../../models/carousel_item.dart';
import '../../../../../providers/color_context.dart';

class EditCarouselItemDialog extends StatefulWidget {
  const EditCarouselItemDialog({
    super.key,
    this.data,
  });

  final CarouselItemModel? data;

  @override
  State<EditCarouselItemDialog> createState() => _EditCarouselItemDialogState();
}

class _EditCarouselItemDialogState extends State<EditCarouselItemDialog> {
  ContextTheme get theme => ContextTheme.of(context);

  MovieController movieController = MovieController();
  OfferController offerController = OfferController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<MovieModel> movies = [];
  List<OfferModel> offers = [];

  List<bool> _selectedLink = <bool>[true, false, false];

  String? selectedMovieId;
  String? selectedOfferId;

  bool isLoading = true;

  Uint8List? image;

  String? title() => titleController.text;

  void fetchMovies() {
    movieController.getAllMovies().then((response) {
      setState(() {
        movies = response;
      });
    }).catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline, context, "Kļūda",
            'Nesanāca dabūt datus par filmam');
      }
      debugPrint(error);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void fetchOffers() {
    offerController.getAllOffers().then((response) {
      setState(() {
        offers = response;
      });
    }).catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline, context, "Kļūda",
            'Nesanāca dabūt datus par piedavājumiem');
      }
      debugPrint(error);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedLink = [
      widget.data?.movie != null,
      widget.data?.offer != null,
      widget.data?.movie == null && widget.data?.offer == null,
    ];

    selectedMovieId = widget.data?.movie?.id;
    selectedOfferId = widget.data?.offer?.id;

    titleController.text = widget.data?.title ?? "";
    descriptionController.text = widget.data?.description ?? "";

    titleController.addListener(() {
      setState(() {});
    });

    fetchMovies();
    fetchOffers();
  }

  void onMovieSelected(String id) {
    setState(() {
      selectedMovieId = id;
    });
  }

  void onOfferSelected(String id) {
    setState(() {
      selectedOfferId = id;
    });
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => image = bytes);
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

  void submit() {
    if (widget.data == null) {
      add();
    } else {
      edit();
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

  void deleteItem() {
    movieController.deleteCarouselItem(widget.data!.id).then((_) {
      if (mounted) {
        StylizedDialog.dialog(Icons.check_circle_outline, context, "Veiksmīgi",
            "Elementi veiksmīgi izdzēsts");
      }
    }).catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline, context, "Kļūda",
            'Neizdevās izdzēst elementu');
      }
      debugPrint(error.message);
    });
    Navigator.of(context).pop();
  }

  void add() {
    if (image == null) {
      StylizedDialog.dialog(
          Icons.error_outline, context, "Kļūda", "Lūdzu pievienojiet bildi");
      return;
    }

    if (titleController.text.isEmpty) {
      StylizedDialog.dialog(
          Icons.error_outline, context, "Kļūda", "Lūdzu ievadiet nosaukumu");
      return;
    }

    if (descriptionController.text.isEmpty) {
      StylizedDialog.dialog(
          Icons.error_outline, context, "Kļūda", "Lūdzu ievadiet aprakstu");
      return;
    }

    MovieModel? movie = movies.cast<MovieModel?>().firstWhere(
          (movie) => movie?.id == selectedMovieId,
          orElse: () => null,
        );

    OfferModel? offer = offers.cast<OfferModel?>().firstWhere(
          (offer) => offer?.id == selectedOfferId,
          orElse: () => null,
        );

    movieController
        .addHomescreenCarousel(
      titleController.text,
      descriptionController.text,
      image,
      null,
      movie,
      offer,
    )
        .catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline, context, "Kļūda",
            'Neizdevās pievienot jauno elementu');
      }
      debugPrint(error.message);
    });
    Navigator.of(context).pop();
  }

  void edit() {
    MovieModel? movie = movies.cast<MovieModel?>().firstWhere(
          (movie) => movie?.id == selectedMovieId,
          orElse: () => null,
        );

    OfferModel? offer = offers.cast<OfferModel?>().firstWhere(
          (offer) => offer?.id == selectedOfferId,
          orElse: () => null,
        );

    movieController
        .updateHomescreenCarousel(
      widget.data!.id,
      titleController.text,
      descriptionController.text,
      image,
      image == null ? widget.data!.imageUrl : null,
      movie,
      offer,
    )
        .catchError((error) {
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline, context, "Kļūda",
            'Neizdevās saglabāt izmaiņas');
      }
      debugPrint(error.message);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1020,
        ),
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 50,
                  children: [
                    imageColumn(),
                    Column(
                      spacing: 25,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          spacing: 10,
                          children: [
                            Text(
                              widget.data?.title == null
                                  ? "Pievienot:"
                                  : "Rediģēt:",
                              style: theme.headlineMedium
                                  .copyWith(color: Colors.white.withAlpha(180)),
                            ),
                            Text(
                              titleController.text,
                              style: theme.displayLarge,
                            ),
                          ],
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 500,
                          ),
                          child: TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nosaukums',
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 500,
                          ),
                          child: TextFormField(
                            controller: descriptionController,
                            minLines: 5,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Apraksts',
                            ),
                          ),
                        ),
                        horizontalDivider(),
                        Text("Piesaistīt saiti:", style: theme.headlineMedium),
                        ToggleButtons(
                          isSelected: _selectedLink,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _selectedLink.length; i++) {
                                _selectedLink[i] = i == index;
                              }
                              if (index == 0) {
                                selectedOfferId = null;
                              } else if (index == 1) {
                                selectedMovieId = null;
                              } else {
                                selectedMovieId = null;
                                selectedOfferId = null;
                              }
                            });
                          },
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          selectedBorderColor: Colors.white30,
                          selectedColor: Colors.white,
                          fillColor: Colors.grey[800],
                          color: Colors.grey[600],
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: const Text("Filma"),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: const Text("Piedavājums"),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: const Text("Nav"),
                            ),
                          ],
                        ),
                        if (_selectedLink[0] && !isLoading) moviesDropdown(),
                        if (_selectedLink[1] && !isLoading) offersDropdown(),
                        if (isLoading)
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white30,
                            size: 50,
                          )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 25,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                      ),
                      child: Text("Atcelt"),
                    ),
                    FilledButton(
                      onPressed: delete,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                      ),
                      child: Text("Dzēst"),
                    ),
                    FilledButton(
                      onPressed: submit,
                      child: Text("Saglabāt izmaiņas"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container horizontalDivider() {
    return Container(
      width: 500,
      decoration: BoxDecoration(
          border: Border(
        top: BorderSide(
          color: Colors.grey[700]!,
          width: 1,
        ),
      )),
    );
  }

  Column imageColumn() {
    return Column(
      spacing: 25,
      children: [
        SizedBox(
          width: 290,
          child: image != null
              ? Image.memory(image!)
              : widget.data?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.data!.imageUrl,
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
          onPressed: pickImage,
          child: Text("Mainīt bildi"),
        ),
      ],
    );
  }

  Container offersDropdown() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      child: DropdownButton(
        items: List.generate(
          offers.length,
          (index) => DropdownMenuItem(
            value: offers[index].id,
            child: Text(offers[index].title),
          ),
        ),
        value: selectedOfferId,
        onChanged: (index) => onOfferSelected(index!),
      ),
    );
  }

  Container moviesDropdown() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      child: DropdownButton(
        items: List.generate(
          movies.length,
          (index) => DropdownMenuItem(
            value: movies[index].id,
            child: Text(movies[index].title),
          ),
        ),
        value: selectedMovieId,
        onChanged: (index) => onMovieSelected(index!),
      ),
    );
  }
}
