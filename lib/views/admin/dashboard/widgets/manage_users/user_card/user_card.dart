import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: userName(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 45),
                          child: userDetails(),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    bottom: 5,
                    left: -10,
                    right: 0,
                    child: editButton(),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(150),
                      blurRadius: 15,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: userImage(),
              )
            ],
          ),
          if (isCurrentUser)
            Positioned(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: classicDecorationWhiteSharper,
                    child: Row(
                      spacing: 10,
                      children: [
                        Icon(
                          Icons.person,
                          color: red001,
                        ),
                        Text(
                          'Jūsu profils',
                          style: bodyMediumRed,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return intl.DateFormat('dd.MM.yyyy').format(date);
  }

  Container userImage() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
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
                child: Icon(
                  Icons.error_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            )
          : Container(
              color: red001,
              child: Icon(
                Icons.person_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget userName() {
    return TextContainer(
      Text(
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
      smokeyWhite,
    );
  }

  Widget userDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        detailRow(
          widget.data.email,
          Icons.email_rounded,
        ),
        detailRow(
          widget.data.role,
          Icons.admin_panel_settings_rounded,
        ),
        detailRow(
          formatDate(widget.data.createdAt.toDate()),
          Icons.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget detailRow(String text, IconData icon) {
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Icon(icon, size: 18, color: Colors.white),
        ],
      ),
      red002,
    );
  }

  Widget editButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: () => widget.onEdit(widget.data.id),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: smokeyWhite.withAlpha(150),
          fixedSize: Size(108, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Center(child: Text("Rediģēt", style: bodyMediumRed)),
            Positioned(
              right: 10,
              child: Icon(Icons.edit, color: red002, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  TextContainer(text, Color color) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: text,
    );
  }
}
