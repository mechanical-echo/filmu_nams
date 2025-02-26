import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/expandable_view/expandable_view.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_header_cell.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_image_cell.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/table/stylized_table_text_cell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomepageCarousel extends StatefulWidget {
  const HomepageCarousel({super.key});

  @override
  State<HomepageCarousel> createState() => _HomepageCarouselState();
}

class _HomepageCarouselState extends State<HomepageCarousel> {
  List<Map<String, dynamic>> carouselItems = [];
  String? selectedDocId;
  bool isEditing = false;
  bool isEditLoading = false;
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
        carouselItems = response
            .map((item) =>
                item.map((key, value) => MapEntry(key, value.toString())))
            .toList();
        isEditLoading = false;
      });
    } catch (e) {
      print('Error fetching carousel items: $e');
      setState(() {
        isEditLoading = false;
      });
    }
  }

  void _handleRowTap(String docId) {
    setState(() {
      selectedDocId = selectedDocId == docId ? null : docId;
      titleController.text =
          carouselItems.firstWhere((item) => item['id'] == docId)['title'];
      descriptionController.text = carouselItems
          .firstWhere((item) => item['id'] == docId)['description'];
      imageUrl =
          carouselItems.firstWhere((item) => item['id'] == docId)['image-url'];
    });
  }

  Future<void> updateCarouselItem() async {
    setState(() {
      isEditLoading = true;
    });
    await MovieController().updateHomescreenCarousel(
      selectedDocId!,
      titleController.text,
      descriptionController.text,
      carouselItems
          .firstWhere((item) => item['id'] == selectedDocId)['image-url'],
    );

    fetchHomescreenCarouselFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableView(
      title: "Sākuma lapas elementi",
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    table(),
                  ],
                ),
              ),
              if (selectedDocId != null)
                Container(
                  width: 600,
                  height: 300,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(color: Colors.white.withAlpha(20)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isEditLoading
                      ? Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 100,
                        ))
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Column(
                                    spacing: 20,
                                    children: [
                                      Text(
                                        "Rediģēt elementu",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 400,
                                        child: TextInput(
                                          controller: titleController,
                                          hintText: "Ievadiet nosaukumu...",
                                          labelText: "Nosaukums",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 400,
                                        child: TextInput(
                                          controller: descriptionController,
                                          hintText: "Ievadiet aprakstu...",
                                          labelText: "Apraksts",
                                        ),
                                      ),
                                    ],
                                  ),
                                  CachedNetworkImage(
                                    imageUrl: imageUrl!,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    height: 200,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  FilledButton(
                                    onPressed: updateCarouselItem,
                                    style: FilledButton.styleFrom(
                                      fixedSize: Size(150, 30),
                                    ),
                                    child: Text(
                                      "Saglabāt",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(
                                      fixedSize: Size(150, 30),
                                    ),
                                    child: Text(
                                      "Dzēst",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
            ],
          ),
          if (selectedDocId == null)
            Text(
              "Lūdzu izvēlieties elementu, lai rediģētu",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget buttonRow() {
    return selectedDocId != null
        ? Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                child: Text("Rediģēt"),
              ),
              FilledButton(
                onPressed: () {},
                child: Text("Dzēst"),
              ),
            ],
          )
        : Text(
            "Lūdzu izvēlieties elementu, lai rediģētu",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          );
  }

  StylizedTable table() {
    return StylizedTable(
      children: [
        TableRow(
          children: [
            StylizedTableHeaderCell(title: "Bilde"),
            StylizedTableHeaderCell(title: "Nosaukums"),
            StylizedTableHeaderCell(title: "Apraksts"),
          ],
        ),
        ...carouselItems.map(
          (item) {
            final docId = item['id'];
            final isSelected = selectedDocId == docId;

            return TableRow(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.fill,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white12 : Colors.transparent,
                    ),
                    child: GestureDetector(
                      onTap: () => _handleRowTap(docId),
                      child:
                          StylizedTableImageCell(imageUrl: item['image-url']),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.fill,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white12 : Colors.transparent,
                    ),
                    child: GestureDetector(
                      onTap: () => _handleRowTap(docId),
                      behavior: HitTestBehavior.opaque,
                      child: StylizedTableTextCell(
                          text: item['title'] ?? "Nav nosaukuma"),
                    ),
                  ),
                ),
                TableCell(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white12 : Colors.transparent,
                    ),
                    child: GestureDetector(
                      onTap: () => _handleRowTap(docId),
                      behavior: HitTestBehavior.opaque,
                      child: StylizedTableTextCell(
                          text: item['description'] ?? "Nav apraksta"),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
