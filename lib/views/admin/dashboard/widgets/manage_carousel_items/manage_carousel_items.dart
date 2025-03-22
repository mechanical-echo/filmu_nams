import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/carousel_item_card/carousel_item_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';

class ManageCarouselItems extends StatefulWidget {
  const ManageCarouselItems({
    super.key,
    required this.action,
  });

  final Function(String, String) action;

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
    return ManageScreen(
      count: carouselItems.length,
      isLoading: isLoading,
      itemGenerator: generateCards(),
      title: "Sākuma lapas elementi",
    );
  }

  generateCards() {
    return (index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: classicDecorationSharp,
          child: CarouselItemCard(
            data: carouselItems[index],
            onEdit: (itemId) {
              widget.action("edit_carousel", itemId);
            },
          ),
        );
  }
}
