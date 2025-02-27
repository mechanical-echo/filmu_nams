import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 170.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StylizedTabs(
              tabs: [
                StylizedTabPage(
                  title: 'Saraksts',
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.red,
                  ),
                ),
                StylizedTabPage(
                  title: 'Visas filmas',
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
