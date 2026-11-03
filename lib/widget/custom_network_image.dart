import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_flutter/utility/constants.dart';

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
      placeholder: (context, url) => _buildLoadingShimmer(),
      errorWidget: (context, url, error) {
        debugPrint('Image load error: $error');
        debugPrint('Image URL: $resolvedUrl');
        return _buildErrorPlaceholder();
      },
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

  Widget _buildLoadingShimmer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
        ),
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
    if (width != null && height != null) {
      return (width! + height!) / 8;
    }
    return 40.0;
  }

  double _getTextSize() {
    if (width != null && height != null) {
      return (width! + height!) / 20;
    }
    return 12.0;
  }
}
