import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/create_chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class CreateChat extends StatelessWidget {
  CreateChat({super.key});

  final CreateChatController controller = Get.put(CreateChatController());

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: GetBuilder<CreateChatController>(
          builder: (controller) => ListView(
            children: [
              _buildHeader(isRtl),
              SizedBox(height: 6.h),
              _buildImagePicker(),
              SizedBox(height: 1.h),
              _buildNameField(),
              SizedBox(height: 1.h),
              _buildPrivacyDropdown(),
              SizedBox(height: 1.h),
              _buildCanDropdown(),
              SizedBox(height: 1.h),
              _buildFormatImageSelector(isRtl),
              SizedBox(height: 4.h),
              Button(
                ontap: controller.createChat,
                text: S.of(context).create,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRtl) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(
          S.of(Get.context!).createNewChat,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 12.h,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.5, color: AppColors.inActiveColor),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: pref!
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x192D4F46),
                    blurRadius: 50,
                    offset: Offset(10, 10),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: controller.fileImgChat == null
              ? _buildImagePlaceholder()
              : _buildSelectedImage(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.cloudUpload,
          size: 6.w,
          color: pref! ? AppColors.whiteColor : AppColors.blackColor,
        ),
        SizedBox(height: 2.h),
        textNormal(
          S.of(Get.context!).roomImage,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          3.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildSelectedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(controller.fileImgChat!.path),
        height: 12.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      height: 6.h,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: TextField(
        controller: controller.nameController,
        style: TextStyle(
          color: pref! ? AppColors.whiteColor : AppColors.inActiveColor,
          fontSize: 3.5.w,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: S.of(Get.context!).name,
          hintStyle: TextStyle(
            color: AppColors.inActiveColor,
            fontSize: 3.5.w,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          data: ThemeData(
            canvasColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          ),
          child: DropdownButton<String>(
            hint: textNormal(
                hint, AppColors.inActiveColor, 3.5.w, FontWeight.w400),
            value: selectedValue.isEmpty ? null : selectedValue,
            isExpanded: true,
            items: options
                .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: textNormal(
                        value,
                        pref! ? AppColors.whiteColor : AppColors.inActiveColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            icon: Icon(
              IconsaxPlusLinear.arrow_down,
              size: 4.w,
              color: AppColors.inActiveColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyDropdown() {
    return _buildDropdown(
      hint: S.of(Get.context!).selectPrivateOrPublic,
      selectedValue: controller.selectedPrivacy,
      options: controller.privacyOptions,
      onChanged: controller.choosePrivacy,
    );
  }

  Widget _buildCanDropdown() {
    return _buildDropdown(
      hint: S.of(Get.context!).selectCan,
      selectedValue: controller.selectedCanChat,
      options: controller.canChatOption,
      onChanged: controller.chooseCan,
    );
  }

  Widget _buildFormatImageSelector(bool isRtl) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isRtl ? 2.w : 4.w, vertical: 2.h),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: GetBuilder<CreateChatController>(
        builder: (controller) => Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            _buildFormatHeader(isRtl),
            const SizedBox(height: 15),
            controller.statuesRequest == StatuesRequest.loading
                ? loading(6.h)
                : _buildThemeSelector(isRtl, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatHeader(bool isRtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        textNormal(
          S.of(Get.context!).chooseChatFormat,
          AppColors.inActiveColor,
          3.5.w,
          FontWeight.w500,
        ),
        GestureDetector(
          onTap: controller.addCustomTheme,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 3.5.w,
                  color: pref! ? AppColors.blackColor : AppColors.whiteColor,
                ),
                SizedBox(width: 1.w),
                textNormal(
                  S.of(Get.context!).addCustom,
                  pref! ? AppColors.blackColor : AppColors.whiteColor,
                  2.8.w,
                  FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(bool isRtl, CreateChatController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          ...controller.themes
              .asMap()
              .entries
              .map((entry) => _buildThemeItem(entry.value, controller)),
          ...controller.customThemeImages
              .map((path) => _buildCustomThemeItem(path, controller)),
        ],
      ),
    );
  }
  Widget _buildThemeItem(dynamic theme, CreateChatController controller) {
    // 🌟 الفحص السحري للرابط عشان ميضربش إيرور
    bool hasValidThemeImage = theme.theme != null && theme.theme.toString().trim().isNotEmpty && theme.theme.toString() != "null";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: GestureDetector(
        onTap: () {
          controller.chooseTheme(theme.id.toString());
          log('Selected theme ID: ${theme.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: controller.themeId == theme.id.toString()
              ? const EdgeInsets.all(2)
              : null,
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.themeId == theme.id.toString()
                  ? pref!
                  ? AppColors.whiteColor
                  : AppColors.blackTextColor
                  : AppColors.inActiveColor,
              width: controller.themeId == theme.id.toString() ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasValidThemeImage
                ? CachedNetworkImage(
              imageUrl: "${theme.theme}",
              width: 20.w,
              height: 10.h,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 20.w,
                height: 10.h,
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.red, size: 4.w),
              ),
            )
                : Container(
              width: 20.w,
              height: 10.h,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported, color: AppColors.inActiveColor, size: 4.w),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCustomThemeItem(String path, CreateChatController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: GestureDetector(
        onTap: () {
          controller.changeToCustom(path);
          log('Selected custom theme: $path');
        },
        onLongPress: () => _showDeleteDialog(path, controller),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: controller.selectedFormat == path
                  ? const EdgeInsets.all(2)
                  : null,
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selectedFormat == path
                      ? pref!
                          ? AppColors.whiteColor
                          : AppColors.blackTextColor
                      : AppColors.inActiveColor,
                  width: controller.selectedFormat == path ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path),
                  width: 20.w,
                  height: 10.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 20.w,
                    height: 10.h,
                    color: Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red, size: 4.w),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color:
                      pref! ? AppColors.secondaryColor : AppColors.buttoncolor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 2.5.w,
                  color: pref! ? AppColors.blackColor : AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String path, CreateChatController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        title: textNormal(
          S.of(Get.context!).deleteCustomTheme,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.w,
          FontWeight.w600,
        ),
        content: textNormal(
          S.of(Get.context!).confirmDeleteCustomTheme,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          3.5.w,
          FontWeight.w400,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: textNormal(S.of(Get.context!).cancel,
                AppColors.inActiveColor, 3.5.w, FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCustomTheme(path);
            },
            child: textNormal(
                S.of(Get.context!).delete, Colors.red, 3.5.w, FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
