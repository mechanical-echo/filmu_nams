import 'package:filmu_nams/assets/theme.dart';
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
                child: Text(widget.title, style: header1),
              ),
              Container(
                decoration: classicDecorationSharper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Text("Kopā: ${widget.count}", style: header1),
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
            child: widget.isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: smokeyWhite,
                      size: 100,
                    ),
                  )
                : GridView.count(
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
      widget.count,
      widget.itemGenerator,
    );
  }
}
