import 'package:flutter/material.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String placeholderAsset;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderAsset = 'assets/images/banner.png',
  });

  @override
  Widget build(BuildContext context) {
    // Use Image.network with loading/error builders to avoid relying on
    // cached_network_image package here. This will show a local asset when
    // loading or when an error occurs.
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Image.asset(
          placeholderAsset,
          width: width,
          height: height,
          fit: fit,
        );
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        placeholderAsset,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
