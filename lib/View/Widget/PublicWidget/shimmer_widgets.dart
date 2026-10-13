import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:shimmer/shimmer.dart';

/// 🌟 مكوّنات شيمر (Skeleton Loading) موحدة وعصرية لكامل التطبيق
/// متجاوبة مع الوضع الداكن (Dark Mode) والوضع الفاتح (Light Mode)
/// آمنة 100% ضد مشاكل الـ Unbounded Height (تستخدم Column بشكل افتراضي)

Color get shimmerBaseColor =>
    (pref ?? false) ? Colors.grey.shade800 : Colors.grey.shade300;

Color get shimmerHighlightColor =>
    (pref ?? false) ? Colors.grey.shade700 : Colors.grey.shade100;

/// 1. شيمر لكروت الشات (مطابق تماماً لـ chatCardWidget)
class ChatListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ChatListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(Get.context ?? context) == TextDirection.rtl;

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: shrinkWrap
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  itemCount,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == itemCount - 1 ? 0 : 2.h,
                    ),
                    child: _buildChatCardSkeleton(isRtl),
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: false,
              physics: physics ?? const NeverScrollableScrollPhysics(),
              padding: padding ?? EdgeInsets.zero,
              itemCount: itemCount,
              separatorBuilder: (_, __) => SizedBox(height: 2.h),
              itemBuilder: (_, __) => _buildChatCardSkeleton(isRtl),
            ),
    );
  }

  Widget _buildChatCardSkeleton(bool isRtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // صورة الشات
              Container(
                width: 19.w,
                height: 19.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              SizedBox(width: 3.w),
              // النصوص (الاسم + آخر رسالة)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40.w,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 28.w,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // زر الانضمام / الدخول
        Container(
          width: 17.w,
          height: 7.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

/// 2. شيمر لقائمة الأشخاص (أصدقاء / طلبات / مقترحات / أعضاء الشات)
class UserListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const UserListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(Get.context ?? context) == TextDirection.rtl;

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: shrinkWrap
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  itemCount,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == itemCount - 1 ? 0 : 2.h,
                    ),
                    child: _buildUserCardSkeleton(isRtl),
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: false,
              physics: physics ?? const NeverScrollableScrollPhysics(),
              padding: padding ?? EdgeInsets.zero,
              itemCount: itemCount,
              separatorBuilder: (_, __) => SizedBox(height: 2.h),
              itemBuilder: (_, __) => _buildUserCardSkeleton(isRtl),
            ),
    );
  }

  Widget _buildUserCardSkeleton(bool isRtl) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // الصورة الدائرية
          Container(
            width: 14.w,
            height: 14.w,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          // البيانات (الاسم + الحالة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 35.w,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 0.8.h),
                Container(
                  width: 22.w,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          // زر الإجراء
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. شيمر للإشعارات (Notifications)
class NotificationListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const NotificationListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(Get.context ?? context) == TextDirection.rtl;

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: shrinkWrap
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  itemCount,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == itemCount - 1 ? 0 : 1.5.h,
                    ),
                    child: _buildNotificationSkeleton(isRtl),
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: false,
              physics: physics ?? const NeverScrollableScrollPhysics(),
              padding: padding ?? EdgeInsets.zero,
              itemCount: itemCount,
              separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
              itemBuilder: (_, __) => _buildNotificationSkeleton(isRtl),
            ),
    );
  }

  Widget _buildNotificationSkeleton(bool isRtl) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: 70.w,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 0.8.h),
                Container(
                  width: 20.w,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. شيمر للـ Pinned Chat (المحادثة الإيجابية المثبتة)
class PinnedChatShimmer extends StatelessWidget {
  const PinnedChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(Get.context ?? context) == TextDirection.rtl;

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Row(
              children: [
                Container(
                  width: 19.w,
                  height: 19.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 35.w,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 24.w,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 17.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
