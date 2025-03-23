import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/offer_controller.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:filmu_nams/views/client/main/offers/offer_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      padding: const EdgeInsets.only(top: 170.0, bottom: 105),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 275,
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white, size: 100))
            : offerData != null && offerData!.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 70),
                    itemCount: offerData!.length,
                    itemBuilder: (context, index) {
                      return OfferCard(
                        data: offerData![index],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Nav pieejamu piedāvājumu",
                      style: bodyMedium,
                    ),
                  ),
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
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: red002,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: data.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      size: 50,
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                data.title,
                style: header2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                data.description,
                style: bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (data.promocode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: classicDecorationWhiteSharper,
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: red001, size: 16),
                          const SizedBox(width: 4),
                          Text("Promokods", style: bodySmallRed),
                        ],
                      ),
                    ),
                  Spacer(),
                  FilledButton(
                    onPressed: () => openOfferView(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: red003,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text("Lasīt vairāk", style: bodySmall),
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
