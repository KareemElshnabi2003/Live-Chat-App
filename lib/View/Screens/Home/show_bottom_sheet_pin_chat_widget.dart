// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/bottm_sheet__controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_field_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetPinChatWidget({required BuildContext context}) {
  Get.put(BottomSheetController());
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (context) => GetBuilder<BottomSheetController>(
      builder: (controller) => _BottomSheetContent(
        controller: controller,
        isRtl: isRtl,
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  final BottomSheetController controller;
  final bool isRtl;

  const _BottomSheetContent({
    required this.controller,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _calculateHeight(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDragHandle(),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateHeight(BuildContext context) {
    final hasSelectedChat = controller.selectChatpIN.value != "";
    final hasTimeSlots = controller.availableTimeSlots.isNotEmpty;
    final hasAds = controller.addAds == S.of(Get.context!).yes;

    if (hasSelectedChat) {
      if (hasAds) {
        return hasTimeSlots ? 110.h : 95.h;
      }
      return hasTimeSlots ? 95.h : 82.h;
    }
    return 65.h;
  }

  Widget _buildDragHandle() {
    return Container(
      height: 4,
      width: 70,
      color: pref! ? AppColors.whiteColor : AppColors.blackColor,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      width: 100.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(context),
          if (MediaQuery.of(context).viewInsets.bottom == 0) _buildPinImages(),
          _buildTitle(context),
          const SizedBox(
            height: 10,
          ),
          if (controller.selectChatpIN.value != "") _buildPriceInfo(context),
          _buildChatDropdown(context),
          const SizedBox(
            height: 10,
          ),
          if (controller.selectChatpIN.value != "") _buildDatePicker(context),
          if (controller.selectChatpIN.value != "" &&
              controller.availableTimeSlots.isNotEmpty)
            _buildTimeSlots(context),
          const SizedBox(
            height: 10,
          ),
          _buildAdOption(context),
          const SizedBox(
            height: 10,
          ),
          if (controller.addAds == S.of(Get.context!).yes)
            _buildAdFields(context),
          _buildNextButton(context),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        textClick(
          S.of(context).close,
          true,
          () {
            Get.back();
          },
          pref! ? AppColors.whiteColor : AppColors.blackColor,
          3.5.w,
        ),
      ],
    );
  }

  Widget _buildPinImages() {
    return Obx(
      () => AnimatedRotation(
        turns: controller.rotationAngle.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: 70.w,
          height: 65.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 10.w,
                child: _buildPinImage(AppImages.pin1Img, 35.w, 65.w),
              ),
              Positioned(
                left: 18.w,
                child: _buildPinImage(AppImages.pin2Img, 35.w, 65.w),
              ),
              Positioned(
                right: 26.w,
                child: _buildPinImage(AppImages.pin3Img, 35.w, 65.w),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinImage(String image, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image)),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return textNormal(
      S.of(context).pinYourChat,
      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
      4.w,
      FontWeight.w600,
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(1.5.h),
          width: 90.w,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            border: Border.all(color: AppColors.inActiveColor),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textNormal(
                "${S.of(context).price} :",
                AppColors.inActiveColor,
                3.w,
                FontWeight.w500,
              ),
              textNormal(
                "${controller.calculateStarsForHours()} ${S.of(context).star}",
                AppColors.blackColor,
                3.w,
                FontWeight.w500,
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildChatDropdown(BuildContext context) {
    return Obx(
      () => controller.isLoadingChats.value
          ? _buildLoadingIndicator(6.h, 92.w)
          : controller.chatsToPin.isEmpty
              ? _buildNoChats(context)
              : SizedBox(
                  width: 92.w,
                  height: 6.h,
                  child: _buildScrollableDropdown(
                    hint: S.of(context).chooseChatToPin,
                    selectedValue: controller.selectChatpIN,
                    options: controller.chatsToPin,
                    onChanged: controller.changeVal,
                    controller: controller,
                  ),
                ),
    );
  }

  Widget _buildLoadingIndicator(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SizedBox(
          width: 5.w,
          height: 5.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNoChats(BuildContext context) {
    return Container(
      height: 6.h,
      width: 92.w,
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: textNormal(
          S.of(context).noChat,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          3.5.w,
          FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: GestureDetector(
            onTap: () => controller.selectDate(context),
            child: Container(
              decoration: ShapeDecoration(
                color: pref! ? AppColors.darkcolor : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller.dateController,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    fontSize: 3.5.w,
                  ),
                  decoration: InputDecoration(
                    hintText: S.of(context).date,
                    hintStyle: TextStyle(
                      color: AppColors.inActiveColor,
                      fontSize: 3.5.w,
                    ),
                    suffixIcon: Icon(
                      IconsaxPlusLinear.calendar_1,
                      color: AppColors.primaryColor,
                      size: 5.w,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: textNormal(
            S.of(context).availableTimes,
            pref! ? AppColors.whiteColor : AppColors.blackTextColor,
            3.5.w,
            FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Obx(
          () => controller.isLoadingTimeSlots.value
              ? _buildLoadingIndicator(8.h, 92.w)
              : Container(
                  width: 92.w,
                  constraints: BoxConstraints(maxHeight: 20.h),
                  decoration: BoxDecoration(
                    color: pref! ? AppColors.darkcolor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.inActiveColor.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: controller.availableTimeSlots.map((timeSlot) {
                          final isAvailable = timeSlot['available'] == true;
                          final isSelected = controller.selectedTimeSlots
                              .contains(timeSlot['time']);
                          return GestureDetector(
                            onTap: isAvailable
                                ? () => controller
                                    .toggleTimeSlotSelection(timeSlot['time'])
                                : null,
                            child: _buildTimeSlotTile(
                                timeSlot, isAvailable, isSelected),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildTimeSlotTile(
      Map<String, dynamic> timeSlot, bool isAvailable, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor
            : isAvailable
                ? (pref! ? AppColors.blackColor : AppColors.whiteColor)
                : AppColors.inActiveColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : isAvailable
                  ? AppColors.inActiveColor
                  : AppColors.inActiveColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable
                ? (isSelected
                    ? IconsaxPlusBold.tick_square
                    : IconsaxPlusLinear.square)
                : IconsaxPlusLinear.close_square,
            size: 3.5.w,
            color: isSelected
                ? AppColors.whiteColor
                : isAvailable
                    ? (pref! ? AppColors.whiteColor : AppColors.blackColor)
                    : AppColors.inActiveColor,
          ),
          SizedBox(width: 1.w),
          textNormal(
            timeSlot['time'],
            isSelected
                ? AppColors.whiteColor
                : isAvailable
                    ? (pref! ? AppColors.whiteColor : AppColors.blackColor)
                    : AppColors.inActiveColor,
            3.w,
            FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget _buildAdOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        textNormal(
          S.of(context).wantToPinAdd,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          3.5.w,
          FontWeight.w600,
        ),
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            _buildRadioOption(context, S.of(context).no),
            _buildRadioOption(context, S.of(context).yes),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(BuildContext context, String value) {
    final isSelected = controller.addAds == value;
    return Row(
      children: [
        textNormal(
          value,
          isSelected
              ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor)
              : AppColors.inActiveColor,
          3.5.w,
          FontWeight.w400,
        ),
        Radio(
          value: value,
          focusColor: isSelected
              ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor)
              : AppColors.inActiveColor,
          activeColor: isSelected
              ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor)
              : AppColors.inActiveColor,
          autofocus: isSelected,
          groupValue: controller.addAds.toString(),
          onChanged: controller.changeAds,
        ),
      ],
    );
  }

  Widget _buildAdFields(BuildContext context) {
    return Column(
      children: [
        // Title field
        SizedBox(
          height: 6.h,
          child: textFieldWidget(
            controller.titleAdsController,
            S.of(context).title,
            false,
            false,
            null,
            TextInputType.text,
            null,
            null,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        SizedBox(height: 1.5.h),

        // Description field
        SizedBox(
          height: 6.h,
          child: textFieldWidget(
            controller.descAdsController,
            S.of(context).descriptionLink,
            false,
            false,
            null,
            TextInputType.text,
            null,
            null,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            lines: false,
          ),
        ),
        SizedBox(height: 1.5.h),

        // Image picker section
        Obx(
          () => GestureDetector(
            onTap: () => controller.pickAdImage(),
            child: Container(
              height: controller.adImage.value != null ? 20.h : 6.h,
              width: 92.w,
              decoration: BoxDecoration(
                color: pref! ? AppColors.darkcolor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.inActiveColor.withOpacity(0.5),
                ),
              ),
              child: controller.adImage.value != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(controller.adImage.value!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.removeAdImage(),
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: const BoxDecoration(
                                color: AppColors.redColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.whiteColor,
                                size: 4.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconsaxPlusLinear.gallery_add,
                          color: AppColors.inActiveColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        textNormal(
                          "Add Image",
                          AppColors.inActiveColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Obx(
      () => Button(
        text: controller.isLoadingPayment.value
            ? S.of(context).loading
            : S.of(context).next,
        ontap: controller.isLoadingPayment.value
            ? null
            : () {
                if (controller.validateAllInputs()) {
                  controller.pinConversation();
                } else {
                  String errorMessage = S.of(context).please_fill_all_fields;

                  // Check specifically for missing image
                  if (controller.addAds == S.of(Get.context!).yes &&
                      controller.adImage.value == null) {
                    errorMessage = "Please add an image for the ad";
                  }

                  Get.snackbar(
                    S.of(context).error,
                    errorMessage,
                    backgroundColor: AppColors.redColor,
                    padding: const EdgeInsets.all(10),
                    borderRadius: 30,
                    colorText: AppColors.blackTextColor,
                    snackPosition: SnackPosition.BOTTOM,
                    snackStyle: SnackStyle.GROUNDED,
                  );
                }
              },
      ),
    );
  }
}

Widget _buildScrollableDropdown({
  required String hint,
  required RxString selectedValue,
  required List<String> options,
  required Function(String?) onChanged,
  required BottomSheetController controller,
}) {
  final uniqueOptions = options.toSet().toList();

  return Container(
    width: double.infinity,
    height: 6.h,
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12),
    decoration: ShapeDecoration(
      color: pref! ? AppColors.darkcolor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: DropdownButtonHideUnderline(
      child: Theme(
        data: ThemeData(
            canvasColor: pref! ? AppColors.darkcolor : AppColors.whiteColor),
        child: Obx(
          () => DropdownButton<String>(
            borderRadius: BorderRadius.circular(20),
            hint: textNormal(
                hint, AppColors.inActiveColor, 3.5.w, FontWeight.w400),
            value: uniqueOptions.isEmpty ||
                    selectedValue.value.isEmpty ||
                    !uniqueOptions.contains(selectedValue.value)
                ? null
                : selectedValue.value,
            isExpanded: true,
            items: _buildDropdownItems(uniqueOptions, controller),
            onChanged: onChanged,
            icon: Icon(
              IconsaxPlusLinear.arrow_down,
              size: 4.w,
              color: AppColors.inActiveColor,
            ),
            menuMaxHeight: 30.h,
          ),
        ),
      ),
    ),
  );
}

List<DropdownMenuItem<String>> _buildDropdownItems(
    List<String> options, BottomSheetController controller) {
  final items = <DropdownMenuItem<String>>[];

  for (var i = 0; i < options.length; i++) {
    items.add(
      DropdownMenuItem<String>(
        value: options[i],
        child: textNormal(
          options[i],
          pref! ? AppColors.whiteColor : AppColors.inActiveColor,
          3.5.w,
          FontWeight.w400,
        ),
      ),
    );

    if (i == options.length - 3 &&
        controller.hasMoreChats &&
        !controller.isLoadingMoreChats.value) {
      items.add(
        DropdownMenuItem<String>(
          value: null,
          enabled: false,
          child: InkWell(
            onTap: controller.loadMoreChats,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 4.w, color: AppColors.primaryColor),
                  SizedBox(width: 2.w),
                  textNormal(S.of(Get.context!).loadMoreChats,
                      AppColors.primaryColor, 3.w, FontWeight.w500),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  if (controller.isLoadingMoreChats.value) {
    items.add(
      DropdownMenuItem<String>(
        value: null,
        enabled: false,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 4.w,
                height: 4.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryColor),
              ),
              SizedBox(width: 2.w),
              textNormal(S.of(Get.context!).loading, AppColors.inActiveColor,
                  3.w, FontWeight.w400),
            ],
          ),
        ),
      ),
    );
  }

  return items;
}
