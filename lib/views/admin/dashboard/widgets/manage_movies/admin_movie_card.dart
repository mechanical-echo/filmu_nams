import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marquee/marquee.dart';

class AdminMovieCard extends StatefulWidget {
  const AdminMovieCard({
    super.key,
    required this.data,
  });

  final MovieModel data;

  @override
  State<AdminMovieCard> createState() => _AdminMovieCardState();
}

class _AdminMovieCardState extends State<AdminMovieCard> {
  Style get theme => Style.of(context);

  OverlayEntry? _overlayEntry;

  void _showHoverPreview(PointerEnterEvent event) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height + 5,
        child: Material(
          elevation: 10,
          child: CachedNetworkImage(
            imageUrl: widget.data.posterUrl,
            width: 230,
            height: 350,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideHoverPreview(PointerExitEvent event) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void onHover() {
    setState(() {
      hovered = true;
    });
  }

  void onHoverExit() {
    setState(() {
      hovered = false;
    });
  }

  bool hovered = false;

  void showEditForm() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditMovieDialog(data: widget.data);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showEditForm,
      child: MouseRegion(
        onEnter: (event) => onHover(),
        onExit: (event) => onHoverExit(),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration:
              hovered ? theme.activeCardDecoration : theme.cardDecoration,
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            spacing: 35,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              image(),
              title(),
              description(),
              Text(
                DateFormat('dd.MM.yyyy.').format(widget.data.premiere.toDate()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded description() {
    return Expanded(
      child: Text(
        widget.data.description,
        style: theme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  SizedBox title() {
    return SizedBox(
      width: 250,
      height: 30,
      child: widget.data.title.length > 21
          ? Marquee(
              text: widget.data.title,
              style: theme.headlineMedium,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 40.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            )
          : Text(widget.data.title, style: theme.headlineMedium),
    );
  }

  MouseRegion image() {
    return MouseRegion(
      onEnter: _showHoverPreview,
      onExit: _hideHoverPreview,
      child: SizedBox(
        width: 150,
        height: 150,
        child: CachedNetworkImage(
          imageUrl: widget.data.posterUrl,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white30,
              size: 100,
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
