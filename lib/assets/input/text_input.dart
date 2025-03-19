import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextInput extends StatefulWidget {
  final bool obscureText;
  final String? hintText;
  final String? labelText;
  final Icon? icon;
  final List<double> margin;
  final TextEditingController controller;
  final String? error;
  final bool obligatory;

  static const defaultMargin = [0.0, 0.0, 0.0, 0.0];

  const TextInput({
    super.key,
    this.obscureText = false,
    this.hintText,
    this.labelText,
    this.icon,
    this.margin = defaultMargin,
    required this.controller,
    this.error,
    this.obligatory = false,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: widget.margin[0],
        right: widget.margin[1],
        bottom: widget.margin[2],
        left: widget.margin[3],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              TextFormField(
                controller: widget.controller,
                cursorColor: const Color.fromARGB(255, 123, 123, 123),
                style: const TextStyle(
                  color: Colors.white,
                ),
                obscureText: _obscureText,
                decoration: InputDecoration(
                  filled: true,
                  hintText: widget.hintText ?? '',
                  labelText: widget.labelText ?? '',
                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggle,
                        )
                      : widget.icon,
                ),
              ),
              if (widget.obligatory)
                Positioned(
                  top: 9,
                  right: -23,
                  child: Text(
                    "*",
                    style: header1,
                  ),
                ),
            ],
          ),
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.error!,
                style: GoogleFonts.poppins(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
