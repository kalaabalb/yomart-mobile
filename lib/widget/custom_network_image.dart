import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_flutter/utility/constants.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:shimmer/shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double scale;
  final double? width;
  final double? height;
  final Color? placeholderColor;
  final Widget? placeholder;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.width,
    this.height,
    this.placeholderColor,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final resolvedUrl = resolveMediaUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: fit,
      scale: scale,
      width: width,
      height: height,
      placeholder: (context, url) => _buildLoadingShimmer(context),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: placeholder ??
          Center(
            child: Icon(
              Icons.image,
              color: Colors.grey[500],
              size: _getIconSize(),
            ),
          ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final base = placeholderColor ??
        (dark ? const Color(0xFF162840) : const Color(0xFFE8EFF7));
    final highlight = dark ? const Color(0xFF294465) : Colors.white;
    final radius = BorderRadius.circular(8);
    final skeleton = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: base, borderRadius: radius),
    );

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (MediaQuery.disableAnimationsOf(context))
            skeleton
          else
            Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              period: const Duration(milliseconds: 1450),
              child: skeleton,
            ),
          Opacity(
            opacity: dark ? .3 : .38,
            child: Image.asset(
              'assets/images/yomart_gold_mark.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: _getIconSize(),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: _getTextSize(),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  double _getIconSize() {
    if (width != null &&
        height != null &&
        width!.isFinite &&
        height!.isFinite) {
      return ((width! + height!) / 8).clamp(20.0, 64.0);
    }
    return 40.0;
  }

  double _getTextSize() {
    if (width != null &&
        height != null &&
        width!.isFinite &&
        height!.isFinite) {
      return ((width! + height!) / 20).clamp(10.0, 18.0);
    }
    return 12.0;
  }
}
