import 'package:flutter/material.dart';

class AuthFormContainer extends StatelessWidget {
  const AuthFormContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(
        top: height * 0.06,
        right: 25,
        left: 25,
        bottom: 25,
      ),
      padding: const EdgeInsets.only(bottom: 25),
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}
