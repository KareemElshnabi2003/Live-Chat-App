//region PinnedAdWidget - Collapsible and Crash-Proof

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:url_launcher/url_launcher.dart';

class PinnedAdWidget extends StatefulWidget {
  final String? adTitle;
  final String? adLink;
  final String? adImage;
  final VoidCallback? onTap;
  final bool pref;

  const PinnedAdWidget({
    super.key,
    this.adTitle,
    this.adLink,
    this.adImage,
    this.onTap,
    required this.pref,
  });

  @override
  State<PinnedAdWidget> createState() => _PinnedAdWidgetState();
}

class _PinnedAdWidgetState extends State<PinnedAdWidget> {
  bool _isCollapsed = false;

  bool _isValidImage(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        url.trim() != "null" &&
        url.trim() != "image";
  }

  String _formatImageUrl(String url) {
    final clean = url.trim();
    if (clean.startsWith('http')) return clean;
    return 'https://api.mayo.live/storage/${clean.replaceAll(RegExp(r'^/'), '')}';
  }

  void _openLink() {
    if (widget.adLink?.isNotEmpty == true && widget.adLink != "null") {
      print("Opening ad link: ${widget.adLink}");
      try {
        final uri = Uri.parse(widget.adLink!);
        launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print("Error opening link: $e");
      }
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool hasValidImage = _isValidImage(widget.adImage);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: widget.pref ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!widget.pref)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(widget.pref ? 0.3 : 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 صورة الإعلان مع إمكانية الطي والتوسيع بسلاسة
          if (hasValidImage)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isCollapsed
                  ? const SizedBox.shrink()
                  : Container(
                      height: 15.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              _formatImageUrl(widget.adImage!)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          // أيقونة التثبيت (Pin)
                          Positioned(
                            top: 10,
                            right: isRtl ? null : 10,
                            left: isRtl ? 10 : null,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                LucideIcons.pin,
                                color: AppColors.whiteColor,
                                size: 4.w,
                              ),
                            ),
                          ),
                          // 🌟 زر سهم طي الصورة في أعلى الصورة
                          Positioned(
                            top: 10,
                            right: isRtl ? 10 : null,
                            left: isRtl ? null : 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCollapsed = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.5.w, vertical: 0.6.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white30,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    textNormal(
                                      isRtl ? "رفع الصورة" : "Collapse",
                                      AppColors.whiteColor,
                                      2.7.w,
                                      FontWeight.w600,
                                    ),
                                    SizedBox(width: 1.w),
                                    Icon(
                                      IconsaxPlusLinear.arrow_up_2,
                                      color: AppColors.whiteColor,
                                      size: 3.8.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          // محتوى الإعلان (العنوان والرابط وزر الطي/التوسيع)
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // في حالة طي الصورة، نظهر أيقونة الدبوس بجانب العنوان
                    if (_isCollapsed || !hasValidImage) ...[
                      Icon(LucideIcons.pin,
                          color: AppColors.primaryColor, size: 4.5.w),
                      SizedBox(width: 2.w),
                    ],
                    Expanded(
                      child: textNormal(
                        widget.adTitle?.isNotEmpty == true &&
                                widget.adTitle != "null"
                            ? widget.adTitle!
                            : (isRtl ? "إعلان مثبت" : "Pinned Ad"),
                        widget.pref
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        3.8.w,
                        FontWeight.w700,
                        maxLines: 1,
                      ),
                    ),
                    // 🌟 زر السهم لرفع / إرجاع الصورة
                    if (hasValidImage)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.5.w, vertical: 0.6.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              textNormal(
                                _isCollapsed
                                    ? (isRtl ? "إظهار الصورة" : "Show Image")
                                    : (isRtl ? "رفع الصورة" : "Collapse"),
                                AppColors.primaryColor,
                                2.8.w,
                                FontWeight.w600,
                              ),
                              SizedBox(width: 1.w),
                              Icon(
                                _isCollapsed
                                    ? IconsaxPlusLinear.arrow_down_1
                                    : IconsaxPlusLinear.arrow_up_2,
                                size: 3.8.w,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.adLink?.isNotEmpty == true &&
                    widget.adLink != "null") ...[
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: _openLink,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            IconsaxPlusLinear.link,
                            size: 4.w,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textNormal(
                                  _getDomainFromUrl(widget.adLink!),
                                  AppColors.primaryColor,
                                  3.2.w,
                                  FontWeight.w600,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 0.2.h),
                                textNormal(
                                  S.of(context).clickHereToVisit,
                                  widget.pref
                                      ? AppColors.inActiveColor
                                      : Colors.grey.shade600,
                                  2.8.w,
                                  FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isRtl
                                ? IconsaxPlusLinear.arrow_left_2
                                : IconsaxPlusLinear.arrow_right_2,
                            size: 4.w,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      if (url.length > 30) {
        return '${url.substring(0, 30)}...';
      }
      return url;
    }
  }
}
//endregion