import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/admin/item_card.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';

class UserCard extends StatefulWidget {
  const UserCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final UserModel data;
  final Function(String) onEdit;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = currentUserId == widget.data.id;

    // Use the base ItemCard with specific content for user cards
    return ItemCard(
      cardWidth: 360, // 170 (details) + 190 (user image)
      leftContent: _buildUserImage(),
      titleWidget: _buildUserName(),
      detailsWidget: _buildUserDetails(),
      actionButton: EditButton(
        onPressed: () => widget.onEdit(widget.data.id),
      ),
      topOverlay: isCurrentUser ? _buildCurrentUserOverlay() : null,
    );
  }

  String formatDate(DateTime date) {
    return intl.DateFormat('dd.MM.yyyy').format(date);
  }

  Widget _buildUserImage() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: widget.data.profileImageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.data.profileImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 50,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: red001,
                child: const Icon(
                  Icons.error_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            )
          : Container(
              color: red001,
              child: const Icon(
                Icons.person_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildUserName() {
    return TextContainer(
      width: 170,
      color: smokeyWhite,
      child: Text(
        widget.data.name,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: red002,
          fontSize: widget.data.name.length > 12 ? 17 : 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailRow(
          widget.data.email,
          Icons.email_rounded,
        ),
        _buildDetailRow(
          widget.data.role,
          Icons.admin_panel_settings_rounded,
        ),
        _buildDetailRow(
          formatDate(widget.data.createdAt.toDate()),
          Icons.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String text, IconData icon) {
    return TextContainer(
      width: 170,
      color: red002,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCurrentUserOverlay() {
    return Positioned(
      top: -50,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -12,
            child: Icon(
              Icons.add_location_rounded,
              color: smokeyWhite,
              size: 50,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: classicDecorationWhiteSharper,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: red001,
                ),
                const SizedBox(width: 10),
                Text(
                  'Jūsu profils',
                  style: bodyMediumRed,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
