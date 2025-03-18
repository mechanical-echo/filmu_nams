import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/carousel_item_card/carousel_item_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageCarouselItems extends StatefulWidget {
  const ManageCarouselItems({
    super.key,
    required this.action,
  });

  final Function(int, String) action;

  @override
  State<ManageCarouselItems> createState() => _ManageCarouselItemsState();
}

class _ManageCarouselItemsState extends State<ManageCarouselItems> {
  List<CarouselItemModel> carouselItems = [];
  String? selectedDocId;
  bool isEditing = false;
  bool isLoading = true;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchHomescreenCarouselFromFirebase();
  }

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getHomescreenCarousel();
      setState(() {
        carouselItems = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching carousel items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: 1300,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: classicDecorationSharper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Text("Sākuma lapas elementi", style: header1),
              ),
              Container(
                decoration: classicDecorationSharper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Text("Kopā: ${carouselItems.length}", style: header1),
              ),
            ],
          ),
        ),
        AnimatedSize(
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 700,
              maxWidth: 1300,
            ),
            decoration: classicDecorationDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: smokeyWhite,
                      size: 100,
                    ),
                  )
                : GridView.count(
                    //TODO: find out how to make responsive gridview
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 20,
                    children: generateCards(),
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> generateCards() {
    return List.generate(
      carouselItems.length,
      (index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: classicDecorationSharp,
        child: CarouselItemCard(
          data: carouselItems[index],
          onEdit: (itemId) {
            widget.action(6, itemId);
          },
        ),
      ),
    );
  }
}
