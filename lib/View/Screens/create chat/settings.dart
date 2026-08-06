// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/setting_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingChatController controller = Get.put(SettingChatController());
  final ScrollController _membersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _membersScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _membersScrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_membersScrollController.position.pixels >=
        _membersScrollController.position.maxScrollExtent - 200) {
      controller.loadMoreMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: GetBuilder<SettingChatController>(
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
              _buildMembersList(isRtl),
              SizedBox(height: 1.h),
              _buildCanDropdown(),
              SizedBox(height: 1.h),
              _buildFormatImageSelector(isRtl),
              // SizedBox(height: 1.h),
              // _buildInviteFriends(isRtl),
              SizedBox(height: 4.h),
              Button(
                ontap: controller.updateChat,
                text: S.of(context).save,
              ),
              SizedBox(height: 2.h),
              _buildDeleteChatButton(isRtl),
              SizedBox(height: 2.h),
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
          S.of(context).update_chat,
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
        width: double.infinity,
        height: 12.h,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.50, color: AppColors.inActiveColor),
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
                  )
                ],
        ),
        child: Center(
          child: controller.fileImgChat == null &&
                  controller.userChatModel!.image.toString() == "null"
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.cloudUpload,
                      size: 6.w,
                      color:
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    textNormal(
                      S.of(context).roomImage,
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                      3.5.w,
                      FontWeight.w500,
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: controller.fileImgChat == null
                      ? CachedNetworkImage(
                          imageUrl: "${controller.userChatModel!.image}",
                          width: double.infinity,
                          height: 12.h,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 12.h,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 4.w,
                            ),
                          ),
                        )
                      : Image.file(
                          File(controller.fileImgChat!.path),
                          width: double.infinity,
                          height: 12.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 12.h,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 4.w,
                            ),
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      width: double.infinity,
      height: 6.h,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: TextField(
        style: TextStyle(
          color: pref! ? AppColors.whiteColor : AppColors.inActiveColor,
          fontSize: 3.5.w,
          fontWeight: FontWeight.w400,
        ),
        controller: controller.nameController,
        decoration: InputDecoration(
          hintText: controller.userChatModel!.name == "null"
              ? S.of(context).name
              : controller.userChatModel!.name,
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

  Widget _buildPrivacyDropdown() {
    return _buildDropdown(
      hint: S.of(context).selectPrivateOrPublic,
      selectedValue: controller.selectedPrivacy,
      options: controller.privacyOptions,
      onChanged: controller.choosePrivacy,
    );
  }

  Widget _buildCanDropdown() {
    return _buildDropdown(
      hint: S.of(context).selectCan,
      selectedValue: controller.selectedCanChat,
      options: controller.canChatOption,
      onChanged: controller.chooseCan,
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String selectedValue,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      width: double.infinity,
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

  Widget _buildMembersList(bool isRtl) {
    if (controller.statuesRequest == StatuesRequest.loading &&
        controller.members.isEmpty) {
      return _buildLoadingContainer(isRtl, height: 20.h);
    }
    if (controller.members.isEmpty &&
        controller.statuesRequest != StatuesRequest.loading) {
      return _buildEmptyMembersContainer(isRtl);
    }
    return _buildMembersContainer(isRtl);
  }

  Widget _buildLoadingContainer(bool isRtl, {required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyMembersContainer(bool isRtl) {
    return Container(
      width: double.infinity,
      height: 10.h,
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Center(
        child: textNormal(
          S.of(context).noMembersFound,
          AppColors.inActiveColor,
          3.5.w,
          FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMembersContainer(bool isRtl) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 40.h),
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textNormal(
                S.of(context).chooseAdmin,
                AppColors.black2TextColor,
                3.5.w,
                FontWeight.w500,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pref! ? AppColors.blackColor : AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: textNormal(
                  '${controller.members.length} = ${S.of(context).members}',
                  AppColors.inActiveColor,
                  2.5.w,
                  FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              controller: _membersScrollController,
              itemCount: controller.members.length +
                  (controller.isLoadingMoreMembers ? 1 : 0) +
                  (!controller.hasMoreMembers && controller.members.isNotEmpty
                      ? 1
                      : 0),
              shrinkWrap: true,
              separatorBuilder: (context, index) =>
                  index >= controller.members.length
                      ? const SizedBox.shrink()
                      : Divider(
                          height: 1,
                          color: AppColors.inActiveColor.withOpacity(0.2)),
              itemBuilder: (context, index) => _buildMemberItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(int index) {
    // Handle loading indicator
    if (index == controller.members.length && controller.isLoadingMoreMembers) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: pref! ? AppColors.whiteColor : AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    // Handle "all members loaded" message
    if (index == controller.members.length && !controller.hasMoreMembers) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: textNormal(
            S.of(context).allMembersLoaded,
            AppColors.inActiveColor,
            3.w,
            FontWeight.w400,
          ),
        ),
      );
    }

    // Safety check - if index is out of bounds, return empty widget
    if (index >= controller.members.length) {
      return const SizedBox.shrink();
    }

    final member = controller.members[index];
    final isSelected = controller.isAdminSelected(member);
    final isOwner =
        sharedPreferences!.getString("id").toString() == member.id.toString();
    final isAdminFromModel = controller.adminIds.contains(member.id.toString());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (pref!
                ? AppColors.blackColor.withOpacity(0.3)
                : AppColors.primaryColor.withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: member.image != null
                  ? CachedNetworkImageProvider("${member.image}")
                  : null,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: member.image == null
                  ? Text(
                      member.username![0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            if (isAdminFromModel)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pref! ? AppColors.darkcolor : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          member.username!,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                isOwner ? S.of(context).owner : member.requestStatus!,
                style: TextStyle(
                  color: isOwner
                      ? AppColors.primaryColor
                      : AppColors.inActiveColor,
                  fontSize: 12,
                  fontWeight: isOwner ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (isAdminFromModel) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    S.of(context).admin,
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: isOwner
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  S.of(context).owner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (value) => controller.toggleAdminSelection(member),
                ),
              ),
        onTap: () => !isOwner ? controller.toggleAdminSelection(member) : null,
      ),
    );
  }

  Widget _buildFormatImageSelector(bool isRtl) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: isRtl ? 2.w : 4.w, vertical: 2.h),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: GetBuilder<SettingChatController>(
        builder: (controller) => Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textNormal(
                  S.of(context).chooseChatFormat,
                  AppColors.inActiveColor,
                  3.5.w,
                  FontWeight.w500,
                ),
                GestureDetector(
                  onTap: controller.addCustomTheme,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: pref!
                          ? AppColors.secondaryColor
                          : AppColors.buttoncolor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 3.5.w,
                          color: pref!
                              ? AppColors.blackColor
                              : AppColors.whiteColor,
                        ),
                        SizedBox(width: 1.w),
                        textNormal(
                          S.of(context).addCustom,
                          pref! ? AppColors.blackColor : AppColors.whiteColor,
                          2.8.w,
                          FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            controller.statuesRequest == StatuesRequest.loading
                ? loading(6.h)
                : SizedBox(
                    height: 12.h,
                    width: double.infinity,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      itemCount: controller.themes.length +
                          controller.customThemeImages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) => _buildThemeItem(index),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeItem(int index) {
    final controller = Get.find<SettingChatController>();
    if (index < controller.themes.length) {
      final theme = controller.themes[index];
      return GestureDetector(
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
            child: CachedNetworkImage(
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
            ),
          ),
        ),
      );
    } else {
      final customThemePath =
          controller.customThemeImages[index - controller.themes.length];
      return GestureDetector(
        onTap: () {
          controller.changeToCustom(customThemePath);
          log('Selected custom theme: $customThemePath');
        },
        onLongPress: () => _showDeleteCustomThemeDialog(customThemePath),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: controller.selectedFormat == customThemePath
                  ? const EdgeInsets.all(2)
                  : null,
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selectedFormat == customThemePath
                      ? pref!
                          ? AppColors.whiteColor
                          : AppColors.blackTextColor
                      : AppColors.inActiveColor,
                  width: controller.selectedFormat == customThemePath ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(customThemePath),
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
      );
    }
  }

  void _showDeleteCustomThemeDialog(String customThemePath) {
    Get.dialog(
      AlertDialog(
        backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        title: textNormal(
          S.of(context).deleteCustomTheme,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.w,
          FontWeight.w600,
        ),
        content: textNormal(
          S.of(context).confirmDeleteCustomTheme,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          3.5.w,
          FontWeight.w400,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: textNormal(
                'Cancel', AppColors.inActiveColor, 3.5.w, FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCustomTheme(customThemePath);
            },
            child: textNormal('Delete', Colors.red, 3.5.w, FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Widget _buildInviteFriends(bool isRtl) {
  //   return Container(
  //     width: double.infinity,
  //     height: 6.h,
  //     padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 12),
  //     decoration: ShapeDecoration(
  //       color: pref! ? AppColors.darkcolor : Colors.white,
  //       shape: RoundedRectangleBorder(
  //         side: const BorderSide(width: 0.50, color: Color(0xFFA29F94)),
  //         borderRadius: BorderRadius.circular(40),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  //       children: [
  //         textNormal(
  //           S.of(context).inviteFriends,
  //           pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
  //           3.5.w,
  //           FontWeight.w400,
  //         ),
  //         Row(
  //           textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  //           children: [
  //             textNormal(
  //               S.of(context).httpFaraena,
  //               pref! ? AppColors.secondaryColor : AppColors.black2TextColor,
  //               3.5.w,
  //               FontWeight.w400,
  //             ),
  //             SizedBox(width: 2.w),
  //             GestureDetector(
  //               onTap: () => Get.snackbar(
  //                   S.of(context).success, S.of(context).linkCopied),
  //               child: Icon(
  //                 IconsaxPlusBold.copy,
  //                 color:
  //                     pref! ? AppColors.secondaryColor : const Color(0xFF243C21),
  //                 size: 5.w,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDeleteChatButton(bool isRtl) {
    return GestureDetector(
      onTap: controller.deleteChat,
      child: SizedBox(
        width: double.infinity,
        height: 5.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            textClick(
              S.of(context).delete,
              false,
              controller.deleteChat,
              AppColors.redColor,
              3.5.w,
            ),
            SizedBox(width: isRtl ? 5 : 10),
            Icon(
              Icons.delete_outline_outlined,
              color: AppColors.redColor,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
