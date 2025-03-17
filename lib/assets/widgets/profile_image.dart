import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage({
    super.key,
    required this.width,
  });

  final double width;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: width,
      height: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0,
            offset: const Offset(6, 8),
          ),
          BoxShadow(
            color: Colors.white24,
            blurRadius: 0,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: user!.photoURL != null
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
          : Icon(
              Icons.person,
              size: 85,
              color: Colors.white,
            ),
    );
  }
}
