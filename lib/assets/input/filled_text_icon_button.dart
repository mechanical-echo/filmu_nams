import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';

class FilledTextIconButton extends StatelessWidget {
  const FilledTextIconButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    required this.paddingY,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final double paddingY;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingY),
      child: StylizedButton(action: onPressed, title: title),
    );
  }
}
