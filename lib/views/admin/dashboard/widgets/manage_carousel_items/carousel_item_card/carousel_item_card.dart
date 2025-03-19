import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CarouselItemCard extends StatefulWidget {
  const CarouselItemCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final CarouselItemModel data;
  final Function(String) onEdit;

  @override
  State<CarouselItemCard> createState() => _CarouselItemCardState();
}

class _CarouselItemCardState extends State<CarouselItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: title(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 45),
                      child: TextContainer(
                        Text(
                          widget.data.description,
                          style: bodyMediumRed,
                          maxLines: widget.data.title.length > 14 ? 4 : 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        smokeyWhite,
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                bottom: 5,
                left: -10,
                right: 0,
                child: button(),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 15,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: poster(),
          )
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Container poster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  title() {
    return TextContainer(
      Text(
        widget.data.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: red002,
          fontSize: widget.data.title.length > 12 ? 17 : 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      smokeyWhite,
    );
  }

  button() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: () => widget.onEdit(widget.data.id),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: smokeyWhite.withAlpha(150),
          fixedSize: Size(108, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Center(child: Text("Rediģēt", style: bodyMediumRed)),
            Positioned(
              right: 10,
              child: Icon(Icons.edit, color: red002, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  TextContainer(text, Color color) {
    return Container(
      width: 175,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: text,
    );
  }
}
