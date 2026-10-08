// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetChangeMusicWidget({required BuildContext context}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  if (!Get.isRegistered<ChatController>()) {
    Get.put(ChatController());
  }

  Get.bottomSheet(
    GetBuilder<ChatController>(
      builder: (controller) => _buildBottomSheetContent(context, controller, isRtl),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    ignoreSafeArea: false,
  );
}Widget _buildBottomSheetContent(BuildContext context, ChatController controller, bool isRtl) {
  // 🌟 خلفية رمادي فاتح شيك عشان الكروت البيضاء تبرز عليها
  final bgColor = pref! ? AppColors.blackColor : const Color(0xFFEBEBEB);

  return Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
      right: 5.w,
      left: 5.w,
      top: 1.5.h,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 3.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(
              S.of(context).chooseWhatYouWantToPlay,
              style: TextStyle(
                color: pref! ? Colors.white : Colors.black87,
                fontSize: 4.5.w,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(1.8.w),
                decoration: BoxDecoration(
                  // 🌟 تغميق زر الإغلاق سنة عشان يظهر
                  color: pref! ? Colors.grey.shade800 : const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.close, color: pref! ? Colors.white : Colors.black87, size: 4.5.w),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),

        Text(
          S.of(context).radioStations,
          style: TextStyle(
            color: pref! ? Colors.white : Colors.black87,
            fontSize: 3.8.w,
            fontWeight: FontWeight.w700,
          ),
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: 2.h),

        SizedBox(
          height: 18.h,
          child: controller.radioStatusRequest == StatuesRequest.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : controller.radioStatusRequest == StatuesRequest.serverException
              ? Center(child: Text(S.of(context).failedToLoadRadioStations))
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.radios.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final radio = controller.radios[index];
              final isPlaying = controller.isRadioPlaying && controller.currentRadioIndex == index;
              return _buildRadioItem(controller, index, radio.name, isPlaying);
            },
          ),
        ),
        SizedBox(height: 2.h),
      ],
    ),
  );
}

Widget _buildRadioItem(ChatController controller, int index, String name, bool isPlaying) {
  return GestureDetector(
    onTap: () {
      if (isPlaying) {
        controller.stopRadio();
      } else {
        controller.playRadio(index);
      }
    },
    child: Container(
      width: 28.w,
      decoration: BoxDecoration(
          color: pref! ? AppColors.darkcolor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // 🌟 إضافة إطار (Border) خفيف جداً وظل أقوى عشان يفصل الكارت عن الخلفية تماماً
          border: pref! ? null : Border.all(color: Colors.grey.shade300, width: 0.8),
          boxShadow: [
            if (!pref!)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
          ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              // 🌟 الدائرة الداخلية أغمق سنة
              color: pref! ? Colors.grey.shade800 : const Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: pref! ? Colors.white : Colors.black87,
              size: 8.w,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              name,
              style: TextStyle(
                color: pref! ? Colors.white : Colors.black87,
                fontSize: 3.3.w,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}