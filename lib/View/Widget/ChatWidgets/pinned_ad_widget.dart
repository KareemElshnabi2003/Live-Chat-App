//region PinnedAdWidget - Refined and Crash-Proof

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:url_launcher/url_launcher.dart';

class PinnedAdWidget extends StatelessWidget {
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
    this.onTap, required this.pref,
  });

  bool _isValidImage(String? url) {
    return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool hasValidImage = _isValidImage(adImage);

    return GestureDetector(
      onTap: () {
        if (adLink?.isNotEmpty == true && adLink != "null") {
          print("Opening ad link: $adLink");
          try {
            final uri = Uri.parse(adLink!);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            print("Error opening link: $e");
          }
        }
        onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: pref ? AppColors.darkcolor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (!pref)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(pref ? 0.3 : 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasValidImage)
              Container(
                height: 15.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(adImage!.trim()),
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
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (adTitle?.isNotEmpty == true && adTitle != "null")
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: textNormal(
                              adTitle!,
                              pref ? AppColors.whiteColor : AppColors.blackTextColor,
                              3.8.w,
                              FontWeight.w700,
                              maxLines: 2,
                            ),
                          ),
                          if (!hasValidImage)
                            Icon(LucideIcons.pin, color: AppColors.primaryColor, size: 4.5.w)
                        ],
                      ),
                    ),
                  if (adLink?.isNotEmpty == true && adLink != "null")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                                  _getDomainFromUrl(adLink!),
                                  AppColors.primaryColor,
                                  3.2.w,
                                  FontWeight.w600,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 0.2.h),
                                textNormal(
                                  S.of(context).clickHereToVisit,
                                  pref ? AppColors.inActiveColor : Colors.grey.shade600,
                                  2.8.w,
                                  FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isRtl ? IconsaxPlusLinear.arrow_left_2 : IconsaxPlusLinear.arrow_right_2,
                            size: 4.w,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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