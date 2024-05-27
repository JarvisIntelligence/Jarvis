import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheImage extends StatelessWidget {
  const CacheImage({super.key, required this.imageUrl, required this.isGroup});

  final String imageUrl;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: (isGroup) ? 15 : 20,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: (isGroup) ? 15 : 20,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: (isGroup) ? 15 : 20,
        child: const Icon(Icons.error),
      ),
    );
  }
}
