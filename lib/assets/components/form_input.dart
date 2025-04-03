import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:filmu_nams/providers/color_context.dart';

class FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final IconData? icon;
  final bool obscureText;
  final String? error;
  final bool obligatory;
  final List<double> margin;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool enabled;

  const FormInput({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.icon,
    this.obscureText = false,
    this.error,
    this.obligatory = false,
    this.margin = const [10, 35, 20, 35],
    this.keyboardType,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(margin[3], margin[0], margin[1], margin[2]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null) ...[
            Text(
              labelText!,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: colors.classicDecorationWhiteSharper,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              if (icon != null)
                Positioned(
                  left: -40,
                  child: Icon(
                    icon,
                    color: colors.color001,
                    size: 25,
                  ),
                ),
              if (obligatory)
                Positioned(
                  right: -20,
                  child: Text(
                    '*',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Text(
                error!,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
