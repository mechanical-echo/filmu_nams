import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BigLogo extends StatelessWidget {
  const BigLogo({super.key, required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: top,
            child: Container(
              width: width,
              height: 94,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Positioned(
            top: (top - 49),
            child: SvgPicture.asset(
              'assets/Logo.svg',
              height: 179,
            ),
          ),
        ],
      ),
    );
  }
}
