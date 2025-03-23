import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.cardWidth,
    required this.leftContent,
    required this.titleWidget,
    required this.detailsWidget,
    required this.actionButton,
    this.topOverlay,
    this.detailsBottomPadding = 45,
  });

  final double cardWidth;
  final Widget leftContent;
  final Widget titleWidget;
  final Widget detailsWidget;
  final Widget actionButton;
  final Widget? topOverlay;
  final double detailsBottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardContent = Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: titleWidget,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(bottom: detailsBottomPadding),
                            child: detailsWidget,
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      bottom: 5,
                      left: -10,
                      right: 0,
                      child: actionButton,
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
                  child: leftContent,
                )
              ],
            ),
            if (topOverlay != null) topOverlay!,
          ],
        );

        final cardContainer = Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: cardContent,
        );

        if (constraints.maxWidth < cardWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: cardContainer,
          );
        }

        return Center(
          child: cardContainer,
        );
      },
    );
  }
}

class TextContainer extends StatelessWidget {
  const TextContainer({
    super.key,
    required this.child,
    required this.color,
    required this.width,
  });

  final Widget child;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
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
      child: child,
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.onPressed,
    this.label = "Rediģēt",
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
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
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: smokeyWhite.withAlpha(150),
          fixedSize: const Size(108, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Center(child: Text(label, style: bodyMediumRed)),
            Positioned(
              right: 10,
              child: Icon(Icons.edit, color: red002, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
