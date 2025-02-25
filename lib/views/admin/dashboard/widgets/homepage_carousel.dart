import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/expandable_view/expandable_view.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_header_cell.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_image_cell.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_text_cell.dart';
import 'package:flutter/material.dart';

class HomepageCarousel extends StatefulWidget {
  const HomepageCarousel({super.key});

  @override
  State<HomepageCarousel> createState() => _HomepageCarouselState();
}

class _HomepageCarouselState extends State<HomepageCarousel> {
  bool isExpanded = false;
  List<Map<String, dynamic>> carouselItems = [];

  @override
  void initState() {
    super.initState();
    fetchHomescreenCarouselFromFirebase();
  }

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getHomescreenCarousel();
      setState(() {
        carouselItems = response
            .map((item) =>
                item.map((key, value) => MapEntry(key, value.toString())))
            .toList();
      });
    } catch (e) {
      print('Error fetching carousel items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableView(
      title: "Sākuma lapas elementi",
      child: StylizedTable(
        children: [
          TableRow(
            children: [
              StylizedTableHeaderCell(title: "Bilde"),
              StylizedTableHeaderCell(title: "Nosaukums"),
              StylizedTableHeaderCell(title: "Apraksts"),
            ],
          ),
          ...carouselItems.map(
            (item) => TableRow(
              children: [
                StylizedTableImageCell(imageUrl: item['image-url']),
                StylizedTableTextCell(text: item['title'] ?? "Nav nosaukuma"),
                StylizedTableTextCell(
                    text: item['description'] ?? "Nav apraksta"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
