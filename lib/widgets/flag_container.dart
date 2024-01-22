import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlagContainer extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const FlagContainer({
    super.key,
    this.imageUrl,
    this.width = 50.0,
    this.height = 40.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(1)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: _buildImageProvider(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  ImageProvider _buildImageProvider() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const AssetImage('assets/logo.png');
    } else if (imageUrl == 'DZD') {
      return const AssetImage('assets/dz.png');
    }
    return CachedNetworkImageProvider(imageUrl!);
  }
}
