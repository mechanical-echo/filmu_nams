import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:filmu_nams/assets/widgets/date_picker/date_picker.dart';

class DatePickerInput extends StatefulWidget {
  const DatePickerInput({
    super.key,
    this.width = 190,
    this.height = 40,
    this.initialValue,
    this.availableDates,
    this.onDateChanged,
    this.padding = const EdgeInsets.all(0),
    this.sharp = false,
  });

  final double width;
  final double height;
  final DateTime? initialValue;
  final List<DateTime>? availableDates;
  final Function(DateTime)? onDateChanged;
  final EdgeInsets padding;
  final bool sharp;

  @override
  State<DatePickerInput> createState() => _DatePickerInputState();
}

class _DatePickerInputState extends State<DatePickerInput>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialValue ?? DateTime.now();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatDate(DateTime t) => DateFormat('y. E d. MMMM', 'lv').format(t);

  Style get style => Style.of(context);

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _removeOverlay,
              child: Container(
                color: Colors.black.withAlpha(125),
              ),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: 340,
                    child: DatePicker(
                      availableDates: widget.availableDates,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                          if (widget.onDateChanged != null) {
                            widget.onDateChanged!(date);
                          }
                          _removeOverlay();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _showOverlay,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: widget.padding,
          width: widget.width,
          height: widget.height,
          decoration: style.cardDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  formatDate(selectedDate),
                  style: style.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: style.contrast.withAlpha(178),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
