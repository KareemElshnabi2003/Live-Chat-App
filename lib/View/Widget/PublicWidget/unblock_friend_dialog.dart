import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Future<void> showUnblockFriendDialog({
  required BuildContext context,
  required dynamic friendId,
  Future<void> Function()? onSendRequest,
  VoidCallback? onCancel,
}) async {
  final bool isDark = pref ?? (Theme.of(context).brightness == Brightness.dark);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Badge Icon
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF243C21).withOpacity(0.35)
                          : const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF81C784).withOpacity(0.3)
                            : const Color(0xFF81C784).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 8.w,
                        color: isDark
                            ? const Color(0xFF81C784)
                            : AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Title
                  Text(
                    S.of(dialogContext).unblockFriendRemovedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 4.6.w,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.whiteColor
                          : AppColors.blackTextColor,
                    ),
                  ),
                  SizedBox(height: 1.2.h),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      S.of(dialogContext).unblockFriendRemovedDesc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 3.5.w,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFFB0B0B0)
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.8.h),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isLoading
                              ? null
                              : () {
                                  Navigator.of(dialogContext).pop();
                                  onCancel?.call();
                                },
                          child: Container(
                            height: 5.5.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              S.of(dialogContext).cancel,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: isDark
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFF64748B),
                                fontSize: 3.6.w,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),

                      // Send Request / Add Button
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  try {
                                    if (onSendRequest != null) {
                                      await onSendRequest();
                                    }
                                  } finally {
                                    if (Navigator.of(dialogContext).canPop()) {
                                      Navigator.of(dialogContext).pop();
                                    }
                                  }
                                },
                          child: Container(
                            height: 5.5.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF81C784).withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 4.w,
                                    height: 4.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: Colors.white,
                                        size: 4.2.w,
                                      ),
                                      SizedBox(width: 1.5.w),
                                      Flexible(
                                        child: Text(
                                          S.of(dialogContext).sendFriendRequest,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            color: Colors.white,
                                            fontSize: 3.6.w,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
