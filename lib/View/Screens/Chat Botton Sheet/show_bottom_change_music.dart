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

  // 🚨 التعديل هنا: التأكد من وجود الكنترولر بدل ما نعمله من جديد
  if (!Get.isRegistered<ChatController>()) {
    Get.put(ChatController());
  }

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => GetBuilder<ChatController>(
      builder: (controller) =>
          _buildBottomSheetContent(context, controller, isRtl),
    ),
  );
}

Widget _buildBottomSheetContent(
    BuildContext context, ChatController controller, bool isRtl) {
  return Container(
    decoration: _buildBottomSheetDecoration(),
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: _getBottomSheetPadding(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(maxHeight: 75.h, minHeight: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            SizedBox(height: 2.h),
            _buildHeader(context, isRtl),
            SizedBox(height: 3.h),
            _buildContent(controller, context),
          ],
        ),
      ),
    ),
  );
}

BoxDecoration _buildBottomSheetDecoration() {
  return BoxDecoration(
    color: _getBackgroundColor(),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(28),
      topRight: Radius.circular(28),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, -5),
      ),
    ],
  );
}

EdgeInsets _getBottomSheetPadding(BuildContext context) {
  return EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
    right: 6.w,
    left: 6.w,
    top: 3.h,
  );
}

Widget _buildDragHandle() {
  return Container(
    width: 12.w,
    height: 5,
    decoration: BoxDecoration(
      color: _getDragHandleColor(),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

Widget _buildHeader(BuildContext context, bool isRtl) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildTitle(context),
      _buildCloseButton(),
    ],
  );
}

Widget _buildTitle(BuildContext context) {
  return Text(
    S.of(context).chooseWhatYouWantToPlay,
    style: TextStyle(
      color: _getTextColor(),
      fontSize: 5.w,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
  );
}

Widget _buildCloseButton() {
  return GestureDetector(
    onTap: () => Get.back(),
    child: Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: _getCloseButtonColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.close,
        color: _getIconColor(),
        size: 5.w,
      ),
    ),
  );
}

Widget _buildContent(ChatController controller, BuildContext context) {
  return Flexible(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentlyPlayingCard(controller, context),
          SizedBox(height: 3.h),
          _buildRadioSection(controller, context),
        ],
      ),
    ),
  );
}

Widget _buildCurrentlyPlayingCard(
    ChatController controller, BuildContext context) {
  if (controller.currentlyPlaying == null && !controller.isRadioPlaying) {
    return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(4.w),
    decoration: _buildCurrentlyPlayingDecoration(),
    child: Row(
      children: [
        _buildMusicIcon(),
        SizedBox(width: 3.w),
        _buildCurrentlyPlayingInfo(controller),
      ],
    ),
  );
}

BoxDecoration _buildCurrentlyPlayingDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primaryColor.withOpacity(0.1),
        AppColors.primaryColor.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.primaryColor.withOpacity(0.2),
      width: 1,
    ),
  );
}

Widget _buildMusicIcon() {
  return Container(
    padding: EdgeInsets.all(3.w),
    decoration: BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(
      Icons.music_note,
      color: AppColors.whiteColor,
      size: 5.w,
    ),
  );
}

Widget _buildCurrentlyPlayingInfo(ChatController controller) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(Get.context!).currentlyPlaying,
          style: TextStyle(
            color: _getSubtitleColor(),
            fontSize: 3.w,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          "",
          style: TextStyle(
            color: _getTextColor(),
            fontSize: 3.8.w,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRadioSection(ChatController controller, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle(S.of(context).radioStations),
      SizedBox(height: 2.h),
      _buildRadioContent(controller, context),
    ],
  );
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      color: _getTextColor(),
      fontSize: 4.2.w,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
  );
}

Widget _buildRadioContent(ChatController controller, BuildContext context) {
  if (controller.radioStatusRequest == StatuesRequest.loading) {
    return _buildLoadingIndicator();
  }

  if (controller.radioStatusRequest == StatuesRequest.serverException) {
    return _buildErrorWidget();
  }

  return _buildRadioList(controller);
}

Widget _buildLoadingIndicator() {
  return SizedBox(
    height: 20.h,
    child: const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        strokeWidth: 3,
      ),
    ),
  );
}

Widget _buildErrorWidget() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: AppColors.redColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.redColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.redColor,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          S.of(Get.context!).failedToLoadRadioStations,
          style: TextStyle(
            color: AppColors.redColor,
            fontSize: 3.5.w,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRadioList(ChatController controller) {
  return SizedBox(
    height: 18.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: controller.radios.length,
      itemBuilder: (context, index) => _buildRadioItem(controller, index),
    ),
  );
}

Widget _buildRadioItem(ChatController controller, int index) {
  final isPlaying =
      controller.isRadioPlaying && controller.currentRadioIndex == index;

  return Padding(
    padding: EdgeInsets.only(right: 3.w),
    child: GestureDetector(
      onTap: () => _onRadioItemTap(controller, index, isPlaying),
      child: _buildRadioItemContainer(isPlaying, index),
    ),
  );
}

void _onRadioItemTap(ChatController controller, int index, bool isPlaying) {
  if (isPlaying) {
    controller.stopRadio();
  } else {
    controller.playRadio(index);
  }
}

Widget _buildRadioItemContainer(bool isPlaying, int index) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 28.w,
    decoration: _buildRadioItemDecoration(isPlaying),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadioIcon(isPlaying),
        SizedBox(height: 1.5.h),
        _buildRadioTitle(index),
      ],
    ),
  );
}

BoxDecoration _buildRadioItemDecoration(bool isPlaying) {
  return BoxDecoration(
    gradient: isPlaying ? _getRadioActiveGradient() : null,
    color: !isPlaying ? _getRadioInactiveColor() : null,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isPlaying ? Colors.transparent : _getRadioBorderColor(),
      width: 1,
    ),
    boxShadow: isPlaying ? [_getRadioShadow()] : [],
  );
}

LinearGradient _getRadioActiveGradient() {
  return LinearGradient(
    colors: [
      AppColors.primaryColor,
      AppColors.primaryColor.withOpacity(0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

Color _getRadioInactiveColor() {
  return pref! ? AppColors.darkcolor : AppColors.whiteColor;
}

Color _getRadioBorderColor() {
  return pref!
      ? AppColors.whiteColor.withOpacity(0.2)
      : AppColors.blackColor.withOpacity(0.1);
}

BoxShadow _getRadioShadow() {
  return BoxShadow(
    color: AppColors.primaryColor.withOpacity(0.3),
    blurRadius: 15,
    offset: const Offset(0, 5),
  );
}

Widget _buildRadioIcon(bool isPlaying) {
  return Container(
    padding: EdgeInsets.all(2.w),
    decoration: BoxDecoration(
      color: _getRadioIconColor(isPlaying),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      isPlaying ? Icons.pause : Icons.play_arrow,
      color: _getRadioIconIconColor(isPlaying),
      size: 6.w,
    ),
  );
}

Color _getRadioIconColor(bool isPlaying) {
  if (isPlaying) return AppColors.whiteColor.withOpacity(0.2);
  return pref!
      ? AppColors.whiteColor.withOpacity(0.1)
      : AppColors.blackColor.withOpacity(0.1);
}

Color _getRadioIconIconColor(bool isPlaying) {
  if (isPlaying) return AppColors.whiteColor;
  return pref! ? AppColors.whiteColor : AppColors.blackColor;
}

Widget _buildRadioTitle(int index) {
  return Text(
    "${S.of(Get.context!).radio} ${index + 1}",
    style: TextStyle(
      color: _getRadioTitleColor(),
      fontSize: 3.2.w,
      fontWeight: FontWeight.w600,
    ),
  );
}

// Color getter methods for better maintainability
Color _getBackgroundColor() {
  return pref! ? AppColors.blackColor : AppColors.bgColor;
}

Color _getDragHandleColor() {
  return (pref! ? AppColors.whiteColor : AppColors.blackColor).withOpacity(0.3);
}

Color _getTextColor() {
  return pref! ? AppColors.whiteColor : AppColors.blackTextColor;
}

Color _getSubtitleColor() {
  return pref! ? AppColors.inActiveColor : AppColors.buttoncolor;
}

Color _getIconColor() {
  return pref! ? AppColors.whiteColor : AppColors.blackColor;
}

Color _getCloseButtonColor() {
  return (pref! ? AppColors.whiteColor : AppColors.blackColor).withOpacity(0.1);
}

Color _getRadioTitleColor() {
  return pref! ? AppColors.whiteColor : AppColors.blackColor;
}