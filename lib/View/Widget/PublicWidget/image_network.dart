import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:live_chat/Core/Constant/app_images.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.errorWidget,
  });

  /// Provides an optimized ImageProvider with memory bounding to prevent OOM
  static ImageProvider provider(String? url, {int maxWidth = 400, int maxHeight = 400}) {
    if (url == null ||
        url.trim().isEmpty ||
        url.trim() == "null" ||
        url.trim() == "image") {
      return const AssetImage(AppImages.noChatImg);
    }
    return CachedNetworkImageProvider(
      url.trim(),
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty || trimmedUrl == "null" || trimmedUrl == "image") {
      return _buildErrorPlaceholder();
    }

    final cacheW = width != null ? (width! * 2.5).round() : 600;
    final cacheH = height != null ? (height! * 2.5).round() : 600;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheW,
        memCacheHeight: cacheH,
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
            size: 26,
          ),
        );
  }
}