import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ErrorWidget extends StatelessWidget {
  final bool isNetworkError;
  final bool isRtl;
  final bool isDarkMode; // Renamed from `pref` for clarity
  final String? errorMessage; // For non-network errors
  final VoidCallback onRetry;

  const ErrorWidget({
    super.key,
    required this.isNetworkError,
    required this.isRtl,
    required this.isDarkMode,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Semantics(
              label: isNetworkError
                  ? S.of(context).noInternet
                  : S.of(context).error,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isNetworkError
                      ? AppColors.secondaryColor.withOpacity(0.1) // Fixed typo
                      : AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError ? LucideIcons.wifiOff : LucideIcons.wifiOff,
                  size: 20.w,
                  color: isNetworkError
                      ? AppColors.secondaryColor // Fixed typo
                      : AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            // Error Title
            Semantics(
              label: 'Error Title',
              child: textNormal(
                isNetworkError
                    ? (isRtl
                        ? "لا يوجد اتصال بالإنترنت"
                        : S.of(context).noInternet)
                    : (isRtl ? "حدث خطأ" : S.of(context).error),
                isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
                4.5.w,
                FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            // Error Message
            Semantics(
              label: 'Error Message',
              child: textNormal(
                isNetworkError
                    ? (isRtl
                        ? "يرجى التحقق من اتصالك بالإنترنت"
                        : S.of(context).noInternetMessage)
                    : errorMessage ?? S.of(context).noInternetMessage,
                isDarkMode
                    ? AppColors.inActiveColor
                    : AppColors.blackColor.withOpacity(0.6),
                3.5.w,
                FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            // Retry Button
            Semantics(
              button: true,
              label: S.of(context).retry,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppColors.secondaryColor // Fixed typo
                      : AppColors.primaryColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  shadowColor: isDarkMode
                      ? AppColors.blackColor.withOpacity(0.3)
                      : AppColors.primaryColor.withOpacity(0.3),
                ),
                icon: Icon(
                  LucideIcons.refreshCw,
                  size: 5.w,
                  color:
                      isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
                ),
                label: textNormal(
                  isRtl ? "إعادة المحاولة" : S.of(context).retry,
                  isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
                  3.5.w,
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
