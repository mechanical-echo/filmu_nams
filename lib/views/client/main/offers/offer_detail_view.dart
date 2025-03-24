import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:filmu_nams/models/promocode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../providers/color_context.dart';

class OfferView extends StatefulWidget {
  const OfferView({
    super.key,
    required this.data,
  });

  final OfferModel data;

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  PromocodeModel? promocode;
  bool isLoadingPromocode = false;

  @override
  void initState() {
    super.initState();
    if (widget.data.promocode != null) {
      setState(() {
        promocode = widget.data.promocode;
      });
    }
  }

  Future<void> copyToClipboard(BuildContext context) async {
    if (promocode != null) {
      await Clipboard.setData(ClipboardData(text: promocode!.name));
      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kopēts!",
          "Promokods ir kopēts uz starpliktuvi",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Piedāvājums',
          style: bodyLarge,
        ),
        centerTitle: true,
        backgroundColor: colors.color002,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: widget.data.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).focusColor,
                    size: 50,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.white, size: 50),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(
                top: 16,
                bottom: 10,
                left: 25,
                right: 25,
              ),
              decoration: colors.classicDecoration,
              child: Text(
                widget.data.title,
                style: header1,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
              child: Text(
                widget.data.description,
                style: colors.bodyMediumThemeColor,
              ),
            ),
            if (widget.data.promocode != null)
              Container(
                margin: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 135,
                ),
                padding: const EdgeInsets.all(16),
                decoration: colors.classicDecoration,
                child: promocode != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Positioned(
                            child: Icon(
                              color: colors.smokeyWhite,
                              Icons.local_offer_rounded,
                              size: 35,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: 16,
                            children: [
                              Column(
                                spacing: 3,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Promokods:',
                                    style: bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  copyButton(context, colors),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    promocode!.percents != null
                                        ? 'Atlaide ${promocode!.percents}%'
                                        : promocode!.amount != null
                                            ? 'Atlaide ${promocode!.amount!.toStringAsFixed(2)}€'
                                            : 'Atlaide',
                                    style: bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Nospiediet, lai kopētu',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'Diemžēl promokods šobrīd nav pieejams',
                          style: bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  GestureDetector copyButton(BuildContext context, ColorContext colors) {
    return GestureDetector(
      onTap: () => copyToClipboard(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: colors.classicDecorationWhiteSharper,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              promocode!.name,
              style: colors.header2ThemeColor,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy,
              color: colors.color001,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
