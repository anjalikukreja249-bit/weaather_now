import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A cached weather icon widget.
/// Wraps [CachedNetworkImage] so every icon in the app is cached on disk,
/// preventing redundant network fetches when scrolling or switching screens.
class CachedWeatherIcon extends StatelessWidget {
  const CachedWeatherIcon({
    super.key,
    required this.url,
    this.size = 40,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      errorWidget: (_, __, ___) => Icon(
        Icons.cloud,
        size: size,
        color: Colors.grey,
      ),
    );
  }
}
