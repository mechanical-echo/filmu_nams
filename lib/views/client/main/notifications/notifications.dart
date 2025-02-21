import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> notifications = [
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
      "Veiksmīgs maksājums",
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 110.0, bottom: 125),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: List.generate(
              notifications.length,
              (index) => NotificationItem(
                notifcationTitle: notifications[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  const NotificationItem({super.key, required this.notifcationTitle});

  final String notifcationTitle;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      alignment: Alignment.topCenter,
      curve: Cubic(.69, -0.29, .4, 1.73),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.only(top: 13, left: 18, right: 18, bottom: 20),
          margin: EdgeInsets.only(
            bottom: isExpanded ? 16 : 6,
            top: 6,
            left: 16,
            right: 16,
          ),
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.notifcationTitle,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.payment,
                      color: Colors.white60,
                      size: 30,
                    ),
                  ],
                ),
              ),
              Text(
                "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                maxLines: isExpanded ? null : 2,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          fixedSize: Size(200, 40),
                        ),
                        child: Text(
                          "Atzimet ka lasito",
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          fixedSize: Size(110, 40),
                        ),
                        child: Text(
                          "Dzest",
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
