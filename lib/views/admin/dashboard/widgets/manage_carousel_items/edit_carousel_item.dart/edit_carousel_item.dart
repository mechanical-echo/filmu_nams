import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditCarouselItem extends StatefulWidget {
  const EditCarouselItem({
    super.key,
    required this.id,
    required this.action,
  });

  final String id;
  final Function(int) action;

  @override
  State<EditCarouselItem> createState() => _EditCarouselItemState();
}

class _EditCarouselItemState extends State<EditCarouselItem> {
  final MovieController _movieController = MovieController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  CarouselItemModel? data;
  bool isLoading = true;

  Future<void> fetchItemData() async {
    try {
      data = await _movieController.getCarouselItemById(widget.id);
      setState(() {
        titleController.text = data!.title;
        descriptionController.text = data!.description;
      });
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.alert(context, "Kļūda", 'Neizdēvas dabūt datus');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateCarouselItem() async {
    setState(() {
      isLoading = true;
    });
    try {
      await MovieController().updateHomescreenCarousel(
        widget.id,
        titleController.text,
        descriptionController.text,
        data!.imageUrl,
      );
    } catch (exception) {
      debugPrint(exception.toString());
      if (mounted) {
        StylizedDialog.alert(context, "Kļūda", "Neizdēvas rediģēt elementu");
      }
    }
    setState(() {
      isLoading = false;
    });

    fetchItemData();
  }

  @override
  void initState() {
    super.initState();
    fetchItemData();
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
      child: isLoading
          ? loading()
          : Center(
              child: Row(
                spacing: 15,
                children: [
                  imageColumn(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 35,
                      ),
                      decoration: classicDecorationSharp,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            spacing: 15,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: classicDecorationWhiteSharper,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 5,
                                    ),
                                    child: Text(
                                      data!.title,
                                      style: header2Red,
                                    ),
                                  ),
                                  StylizedButton(
                                    action: () => widget.action(0),
                                    title: "Atpakaļ",
                                    icon: Icons.chevron_left_rounded,
                                    textStyle: header2Red,
                                    iconSize: 35,
                                  ),
                                ],
                              ),
                              Divider(height: 20),
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.text_fields_rounded,
                                    size: 25,
                                    color: smokeyWhite,
                                  ),
                                  Text("Nosaukums", style: bodyLarge),
                                ],
                              ),
                              TextFormField(
                                controller: titleController,
                              ),
                              Container(),
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.text_snippet_rounded,
                                    size: 25,
                                    color: smokeyWhite,
                                  ),
                                  Text("Apraksts", style: bodyLarge),
                                ],
                              ),
                              TextFormField(
                                controller: descriptionController,
                                keyboardType: TextInputType.multiline,
                                minLines: 5,
                                maxLines: 5,
                              ),
                            ],
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StylizedButton(
                                  action: updateCarouselItem,
                                  title: "Saglabāt izmaiņas",
                                  icon: Icons.save,
                                ),
                                StylizedButton(
                                  action: () {},
                                  title: "Dzēst elementu",
                                  icon: Icons.delete_forever,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Container imageColumn() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 490,
      ),
      decoration: classicDecorationSharp,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Column(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: cardShadow,
            ),
            child: CachedNetworkImage(
              imageUrl: data!.imageUrl,
              placeholder: (context, url) => loading(),
            ),
          ),
          SizedBox(height: 20),
          StylizedButton(
            action: () {},
            title: "Mainīt bildi",
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
