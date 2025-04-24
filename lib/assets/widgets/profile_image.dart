import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage({
    super.key,
    required this.width,
    this.customImage,
  });

  final double width;
  final File? customImage;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      width: width,
      height: width,
      decoration: theme.cardDecoration,
      child: user!.photoURL != null && customImage == null
          ? CachedNetworkImage(
              imageUrl: user!.photoURL!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    size: 50,
                    color: Theme.of(context).focusColor,
                  ),
                ),
              ),
            )
          : customImage != null
              ? Image.file(
                  customImage!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.person,
                  size: 85,
                  color: Colors.white,
                ),
    );
  }
}
