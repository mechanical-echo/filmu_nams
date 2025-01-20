import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final bool obscureText;
  final String? hintText;
  final String? labelText;
  final Icon? icon;
  final List<double> margin;

  static const defaultMargin = [0.0, 0.0, 0.0, 0.0];

  const TextInput({
    super.key,
    this.obscureText = false,
    this.hintText,
    this.labelText,
    this.icon,
    this.margin = defaultMargin,
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
      child: TextFormField(
        cursorColor: const Color.fromARGB(255, 123, 123, 123),
        style: const TextStyle(
          color: Colors.white,
        ),
        obscureText: _obscureText,
        decoration: InputDecoration(
          filled: true,
          hintText: widget.hintText ?? 'dro\$aParole1',
          labelText: widget.labelText ?? 'Parole',
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _toggle,
                )
              : widget.icon,
        ),
      ),
    );
  }
}
