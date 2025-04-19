import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({
    super.key,
    required this.count,
    required this.isLoading,
    required this.itemGenerator,
    required this.title,
  });

  final int count;
  final bool isLoading;
  final Widget Function(int) itemGenerator;
  final String title;

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  ContextTheme get theme => ContextTheme.of(context);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double calculatedWidth() => width * 0.9;
    double calculatedHeight() => height * 0.7;

    double itemWidth = 400.0;
    double itemHeight = 320.0;

    int calculateItemsPerRow(double containerWidth) {
      int itemsPerRow = (containerWidth / (itemWidth + 20)).floor();
      return itemsPerRow > 0 ? itemsPerRow : 1;
    }

    return Column(
      spacing: 10,
      children: [
        header(calculatedWidth()),
        Container(
          constraints: BoxConstraints(
            maxHeight: 1050,
            maxWidth: calculatedWidth(),
          ),
          decoration: theme.cardDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: widget.isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: smokeyWhite,
                    size: 100,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double availableWidth = constraints.maxWidth;
                    int itemsPerRow = calculateItemsPerRow(availableWidth);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                        childAspectRatio: itemWidth / itemHeight,
                        mainAxisExtent: 80,
                      ),
                      itemCount: widget.count,
                      itemBuilder: (context, index) =>
                          widget.itemGenerator(index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  header(double calculatedWidth) {
    return SizedBox(
      width: calculatedWidth,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 20,
        runSpacing: 10,
        children: [
          Container(
            decoration: theme.activeCardDecoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.title, style: theme.displayLarge),
            ),
          ),
          Container(
            decoration: theme.cardDecoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Kopā: ${widget.count}", style: theme.displayMedium),
            ),
          ),
        ],
      ),
    );
  }
}
