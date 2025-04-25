import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({
    super.key,
    required this.count,
    required this.isLoading,
    required this.itemGenerator,
    required this.title,
    this.onCreate,
    this.height = 40,
  });

  final int count;
  final bool isLoading;
  final Widget Function(int) itemGenerator;
  final Function()? onCreate;
  final String title;
  final double height;

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double calculatedWidth() => width * 0.9;

    double itemWidth = 400.0;
    double itemHeight = 320.0;

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
                    color: Colors.white,
                    size: 100,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 20,
                        childAspectRatio: itemWidth / itemHeight,
                        mainAxisExtent: widget.height,
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
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: [
          IntrinsicWidth(
            child: Row(
              spacing: 15,
              children: [
                Container(
                  decoration: theme.cardDecoration,
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
                    child: Text(
                      "Kopā: ${widget.count}",
                      style: theme.displayLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onCreate != null)
            FilledButton(
              onPressed: widget.onCreate,
              child: Text(
                "Pievienot +",
                style: theme.displayMedium,
              ),
            ),
        ],
      ),
    );
  }
}
