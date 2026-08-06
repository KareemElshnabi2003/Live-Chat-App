import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget; // لو حابب تمرر شكل error مختلف في شاشات معينة

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 1. حماية أولية: لو الرابط فاضي أصلاً
    if (imageUrl.trim().isEmpty) {
      return _buildErrorPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // 2. أثناء التحميل (تقدر تبدلها بـ Shimmer لو تحب)
        placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        // 3. في حالة حدوث إيرور (رابط بايظ، سيرفر واقع)
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      ),
    );
  }

  // الويدجت اللي هتظهر لو فيه مشكلة في الصورة
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
            Icons.broken_image_rounded, // أيقونة تعبر عن عدم وجود صورة
            color: Colors.grey,
            size: 30,
          ),
        );
  }
}