import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/offer_controller.dart';
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

  Future<void> fetchOffers() async {
    try {
      final response = await OfferController().getAllOffers();
      setState(() {
        offerData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching offers: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Piedāvājumi',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Īpašie piedāvājumi un akcijas',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
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
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
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
    return GestureDetector(
      onTap: () => openOfferView(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    data.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    data.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  Row(
                    children: [
                      if (data.promocode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Promokods",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
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
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Lasīt vairāk",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white.withOpacity(0.8),
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
