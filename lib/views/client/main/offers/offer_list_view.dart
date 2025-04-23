import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:filmu_nams/views/client/main/offers/offer_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../providers/color_context.dart';

class OffersList extends StatefulWidget {
  const OffersList({super.key});

  @override
  State<OffersList> createState() => _OffersListState();
}

class _OffersListState extends State<OffersList> {
  List<OfferModel>? offerData;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _offerFetchSubscription;

  @override
  void dispose() {
    _offerFetchSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchOffers() async {
    _offerFetchSubscription =
        _firestore.collection('offers').snapshots().listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => OfferModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        offerData = items;
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to carousel changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ContextTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Piedāvājumi 💯',
                  style: theme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Īpašie piedāvājumi un akcijas',
                  style: theme.titleMedium,
                ),
              ],
            ),
          ),

          // Offers list
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                : offerData != null && offerData!.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: offerData!.length,
                        itemBuilder: (context, index) {
                          return OfferCard(
                            data: offerData![index],
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              color: Colors.white.withOpacity(0.5),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Nav pieejamu piedāvājumu",
                              style: theme.titleMedium,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.data,
  });

  final OfferModel data;

  void openOfferView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferView(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ContextTheme.of(context);
    return GestureDetector(
      onTap: () => openOfferView(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: theme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: data.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: theme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (data.promocode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.contrast.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: theme.contrast.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Promokods",
                                style: GoogleFonts.poppins(
                                  color: theme.contrast.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.contrast.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Lasīt vairāk",
                              style: theme.titleSmall,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: theme.contrast.withOpacity(0.8),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
