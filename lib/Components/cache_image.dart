import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:lottie/lottie.dart';

class CacheImage extends StatelessWidget {
  const CacheImage({super.key, required this.imageUrl,
    required this.isGroup, required this.numberOfUsers});

  final String imageUrl;
  final bool isGroup;
  final String numberOfUsers;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: (isGroup)
            ? (int.parse(numberOfUsers) > 2)
              ? 12
              : 15
            : 20,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius:(isGroup)
            ? (int.parse(numberOfUsers) > 2)
              ? 12
              : 15
            : 20,
        child: Lottie.asset('assets/lottie_animations/loading_animation.json')
      ),
      errorWidget: (context, url, error) {
        // onImageLoadFailed(error); // Call the function when image loading fails
        return CircleAvatar(
            radius: (isGroup)
                ? (int.parse(numberOfUsers) > 2)
                  ? 12
                  : 15
                : 20,
            backgroundImage: const AssetImage('assets/icons/blank_profile.png'),
        );
      }
    );
  }
}
