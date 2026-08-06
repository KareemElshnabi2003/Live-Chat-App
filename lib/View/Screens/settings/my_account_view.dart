// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/my_profile_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class MyAccountView extends StatelessWidget {
  MyAccountView({super.key});
  final MyAccountController controller = Get.put(MyAccountController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Obx(() => Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: isRtl ? 4.w : 4.w,
                    top: 2.h,
                    right: isRtl ? 4.w : 4.w),
                child: Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: isRtl
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.start,
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(isRtl ? 1.5.w : 2.w),
                              child: Icon(
                                isRtl
                                    ? IconsaxPlusLinear.arrow_right_3
                                    : IconsaxPlusLinear.arrow_left_1,
                                size: 5.5.w,
                                color: pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                            ),
                          ),
                          SizedBox(width: isRtl ? 1.5.w : 2.w),
                          textNormal(
                            S.of(context).myAccount,
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            4.5.w,
                            FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      textNormal(
                        S.of(context).editInformation,
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w500,
                      ),
                      SizedBox(height: 3.h),
                      _buildProfileImage(),
                      SizedBox(height: 3.h),
                      _buildEditableField(
                        controller: controller.nameController,
                        hintText: S.of(context).enterFullName,
                        icon: IconsaxPlusLinear.profile,
                        isRequired: true,
                      ),
                      _buildEditableField(
                        controller: controller.usernameController,
                        hintText: S.of(context).enterUsername,
                        icon: IconsaxPlusLinear.profile_tick,
                      ),
                      _buildEditableField(
                        controller: controller.bioController,
                        hintText: "Bio",
                        icon: IconsaxPlusLinear.profile_tick,
                      ),
                      _buildEditableField(
                        controller: controller.emailController,
                        hintText: S.of(context).enterEmail,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                      ),
                      _buildEditableField(
                        controller: controller.countryController,
                        hintText: S.of(context).enterCountry,
                        icon: IconsaxPlusLinear.location,
                      ),
                      _buildEditableField(
                        controller: controller.ageController,
                        hintText: S.of(context).enterAge,
                        icon: IconsaxPlusLinear.calendar,
                        keyboardType: TextInputType.number,
                      ),
                      _buildGenderSelector(),
                      _buildEditableField(
                        controller: controller.phoneController,
                        hintText: S.of(context).enterMobileNumber,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 2.h),
                      Button(
                        ontap: controller.saveUserData,
                        text: S.of(context).saveChanges,
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading.value)
                Container(
                  color: pref!
                      ? AppColors.whiteColor
                      : Colors.black.withOpacity(0.3),
                  child: Center(
                    child: textNormal(
                      S.of(context).loading,
                      pref! ? AppColors.blackColor : AppColors.whiteColor,
                      4.w,
                      FontWeight.w500,
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildProfileImage() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        width: double.infinity,
        height: 19.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            side: pref!
                ? const BorderSide(color: AppColors.inActiveColor)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Stack(
          children: [
            Obx(() => controller.profileImagePath.isNotEmpty
                ? Positioned.fill(
                    child: Image.file(
                      File(controller.profileImagePath.value),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Positioned.fill(
                    child: Image(
                      image: AssetImage(AppImages.profileimage),
                      fit: BoxFit.contain,
                    ),
                  )),
            Positioned(
              left: isRtl ? null : 3.w,
              right: isRtl ? 3.w : null,
              bottom: 1.5.h,
              child: Container(
                width: 4.5.h,
                height: 4.h,
                decoration: ShapeDecoration(
                  color: pref! ? AppColors.blackColor : const Color(0xFFF4F2E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: [
                    BoxShadow(
                      color: pref!
                          ? AppColors.whiteColor
                          : Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    IconsaxPlusLinear.camera,
                    size: 5.w,
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(
                  fontSize: 4.w,
                  fontWeight: FontWeight.w400,
                  color:
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 4.w,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inActiveColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(
              icon,
              size: 5.5.w,
              color: AppColors.inActiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return GestureDetector(
      onTap: _showGenderBottomSheet,
      child: Container(
        width: double.infinity,
        height: 6.h,
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: ShapeDecoration(
          color: pref! ? AppColors.darkcolor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
              left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Obx(() => textNormal(
                    controller.selectedGender.isEmpty
                        ? S.of(Get.context!).selectGender
                        : controller.selectedGender.value,
                    controller.selectedGender.isEmpty
                        ? AppColors.inActiveColor
                        : pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                    4.w,
                    FontWeight.w400,
                  )),
              Icon(
                isRtl
                    ? IconsaxPlusLinear.arrow_down
                    : IconsaxPlusLinear.arrow_down,
                size: 5.5.w,
                color: AppColors.inActiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenderBottomSheet() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    Get.bottomSheet(
      Container(
        color: pref! ? AppColors.blackColor : AppColors.whiteColor,
        padding: EdgeInsets.all(isRtl ? 2.w : 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: pref! ? AppColors.blackColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            textNormal(
              S.of(Get.context!).selectGender,
              pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              4.5.w,
              FontWeight.w600,
            ),
            SizedBox(height: 3.h),
            ...controller.genderOptions.map((gender) => ListTile(
                  title: Text(
                    gender,
                    style: TextStyle(
                      color:
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                    ),
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  leading: isRtl
                      ? null
                      : Obx(() => Radio<String>(
                            value: gender,
                            groupValue: controller.selectedGender.value,
                            onChanged: (value) {
                              controller.selectedGender.value = value!;
                              Get.back();
                            },
                          )),
                  trailing: isRtl
                      ? Obx(() => Radio<String>(
                            value: gender,
                            groupValue: controller.selectedGender.value,
                            onChanged: (value) {
                              controller.selectedGender.value = value!;
                              Get.back();
                            },
                          ))
                      : null,
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
