import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/models/offer_model.dart';
import 'package:filmu_nams/models/promocode_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OfferView extends StatefulWidget {
  const OfferView({
    super.key,
    required this.data,
  });

  final OfferModel data;

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView>
    with SingleTickerProviderStateMixin {
  PromocodeModel? promocode;
  bool isLoadingPromocode = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.data.promocode != null) {
      setState(() {
        promocode = widget.data.promocode;
      });
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> copyToClipboard(BuildContext context) async {
    if (promocode != null) {
      await Clipboard.setData(ClipboardData(text: promocode!.name));
      if (mounted) {
        StylizedDialog.dialog(
          Icons.paste,
          context,
          "Kopēts!",
          "Promokods ir kopēts uz starpliktuvi",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);

    return Scaffold(
      backgroundColor: theme.themeBgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.themeBgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back,
              color: theme.contrast,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'offer_image_${widget.data.id}',
              child: CachedNetworkImage(
                imageUrl: widget.data.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      size: 50,
                      color: theme.contrast,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: Icon(
                    Icons.error,
                    color: theme.contrast,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.themeBgColor.withOpacity(0.5),
                    theme.themeBgColor.withOpacity(0.8),
                    theme.themeBgColor,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.8],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          widget.data.title,
                          style: theme.displayLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          widget.data.description,
                          style: GoogleFonts.poppins(
                            color: theme.contrast.withOpacity(0.8),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    if (widget.data.promocode != null) ...[
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: theme.cardDecoration,
                            child: promocode != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_offer,
                                            color:
                                                theme.contrast.withOpacity(0.8),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Promokods',
                                            style: GoogleFonts.poppins(
                                              color: theme.contrast,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () => copyToClipboard(context),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration:
                                              theme.activeCardDecoration,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                promocode!.name,
                                                style: GoogleFonts.poppins(
                                                  color: theme.contrast,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.copy,
                                                color: theme.contrast
                                                    .withOpacity(0.8),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        promocode!.percents != null
                                            ? 'Atlaide ${promocode!.percents}%'
                                            : promocode!.amount != null
                                                ? 'Atlaide ${promocode!.amount!.toStringAsFixed(2)}€'
                                                : 'Atlaide',
                                        style: GoogleFonts.poppins(
                                          color:
                                              theme.contrast.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nospiediet, lai kopētu',
                                        style: GoogleFonts.poppins(
                                          color:
                                              theme.contrast.withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'Diemžēl promokods šobrīd nav pieejams',
                                      style: GoogleFonts.poppins(
                                        color: theme.contrast.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
