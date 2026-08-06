import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Controller/page_start_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/otp_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_field_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetWidget(
    {required BuildContext context, required Function(String) onPressSubmit}) {

  // 🚨 التعديل هنا: التأكد من عدم إنشاء Controller جديد لو كان موجود بالفعل لتجنب الـ Memory Leak
  if (!Get.isRegistered<PageStartController>()) {
    Get.put(PageStartController());
  }

  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (context) => SafeArea(
      child: GetBuilder<PageStartController>(
        builder: (c) => AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 4.w,
            right: 4.w,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: MediaQuery.of(context).viewInsets.bottom > 0
                ? c.sheetName == "register2"
                ? 70.h
                : c.sheetName == 'verifyLogin' ||
                c.sheetName == 'verifyRegister'
                ? 55.h
                : 60.h
                : c.sheetName == 'verifyLogin' ||
                c.sheetName == 'verifyRegister'
                ? 55.h
                : c.sheetName == "register2"
                ? 65.h
                : 60.h,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Safe area top padding
                  SizedBox(
                      height: MediaQuery.of(context).padding.top > 0 ? 8 : 0),
                  Container(
                    height: 4,
                    width: 70,
                    color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
                    width: 100.w,
                    child: Form(
                      key: c.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back/Create Account Button
                          Row(
                            mainAxisAlignment: isRtl
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              textClick(
                                c.sheetName == 'Login'
                                    ? S.of(context).create_account
                                    : c.sheetName == 'register2'
                                    ? S.of(context).log_in
                                    : S.of(context).back,
                                true,
                                    () {
                                  if (c.sheetName == 'Login') {
                                    c.emailController.clear();
                                    c.updateSheet('register2');
                                  } else if (c.sheetName == 'register2') {
                                    c.emailController.clear();
                                    c.nameController.clear();
                                    c.userNameController.clear();
                                    c.updateSheet('Login');
                                  } else if (c.sheetName == 'register1') {
                                    c.updateSheet('register2');
                                  } else if (c.sheetName == 'verifyLogin') {
                                    c.updateSheet('Login');
                                  } else if (c.sheetName == 'verifyRegister') {
                                    c.updateSheet('register1');
                                  }
                                },
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                                3.5.w,
                              ),
                            ],
                          ),
                          // Image Section
                          Stack(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  final slideIn = Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  final slideOut = Tween<Offset>(
                                    begin: Offset.zero,
                                    end: const Offset(0, 1),
                                  ).animate(animation);
                                  return AnimatedBuilder(
                                    animation: animation,
                                    child: child,
                                    builder: (context, child) {
                                      final isReverse = animation.status ==
                                          AnimationStatus.reverse;
                                      return SlideTransition(
                                        position:
                                        isReverse ? slideOut : slideIn,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  );
                                },
                                layoutBuilder:
                                    (currentChild, previousChildren) => Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                ),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: Container(
                                  key: c.imageKey,
                                  width: 70.w,
                                  height: c.sheetName == 'verifyLogin' ||
                                      c.sheetName == 'verifyRegister'
                                      ? 60.w
                                      : 65.w,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: c.sheetName == 'verifyLogin' ||
                                          c.sheetName == 'Login'
                                          ? const AssetImage(AppImages.loginImg)
                                          : const AssetImage(
                                          AppImages.registerImg),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              // Shadow Overlay
                              Positioned(
                                bottom: 0,
                                right: 3.w,
                                left: 3.w,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 30,
                                          blurStyle: BlurStyle.normal,
                                          color: pref!
                                              ? AppColors.blackColor
                                              : AppColors.whiteColor,
                                          offset: const Offset(0, -9),
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          blurRadius: 30,
                                          blurStyle: BlurStyle.normal,
                                          color: pref!
                                              ? AppColors.blackColor
                                              : AppColors.whiteColor,
                                          offset: const Offset(0, -9),
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    width: 70.w,
                                    height: c.sheetName == 'verifyLogin' ||
                                        c.sheetName == 'verifyRegister'
                                        ? 10.w
                                        : 10.w,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: isRtl ? -10.w : 0,
                                left: isRtl ? 0 : -10.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: pref!
                                        ? AppColors.blackColor
                                        : AppColors.bgColor,
                                  ),
                                  width: 100.w,
                                  height: c.sheetName == 'verifyLogin' ||
                                      c.sheetName == 'verifyRegister'
                                      ? 12.w
                                      : 14.w,
                                ),
                              ),
                            ],
                          ),
                          // Title Text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              final inAnimation = Tween<Offset>(
                                begin: isRtl
                                    ? const Offset(1.0, 0.0)
                                    : const Offset(-1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation);
                              final outAnimation = Tween<Offset>(
                                begin: Offset.zero,
                                end: isRtl
                                    ? const Offset(-1.0, 0.0)
                                    : const Offset(1.0, 0.0),
                              ).animate(animation);
                              return SlideTransition(
                                position:
                                animation.status == AnimationStatus.reverse
                                    ? outAnimation
                                    : inAnimation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              key: ValueKey(c.sheetName),
                              c.sheetName == 'verifyLogin'
                                  ? S.of(context).enter_the_code_sent
                                  : c.sheetName == 'Login'
                                  ? S.of(context).enter_your_email_address
                                  : S.of(context).create_account,
                              textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                fontSize: 4.w,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          // Subtitle Text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              key: ValueKey(c.sheetName),
                              c.sheetName == 'verifyLogin'
                                  ? S.of(context).you_must_verify_email
                                  : c.sheetName == 'verifyRegister'
                                  ? S.of(context).fill_in_details_zero_steps
                                  : c.sheetName == 'Login'
                                  ? S
                                  .of(context)
                                  .enter_email_to_complete
                                  : c.sheetName == 'register1'
                                  ? S
                                  .of(context)
                                  .fill_in_information_one_step
                                  : S
                                  .of(context)
                                  .fill_in_details_two_steps,
                              textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: pref!
                                    ? AppColors.inActiveColor
                                    : AppColors.black2TextColor,
                                fontSize: 3.5.w,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Input Field or OTP
                          SizedBox(
                            width: 92.w,
                            height: c.sheetName == 'verifyLogin' ||
                                c.sheetName == 'verifyRegister'
                                ? 7.h
                                : 9.h,
                            child: c.sheetName == 'verifyLogin' ||
                                c.sheetName == 'verifyRegister'
                                ? c.statuesRequest == StatuesRequest.loading
                                ? loading(7.h)
                                : otpWidget(c.verifyCode, onPressSubmit)
                                : textFieldWidget(
                              c.sheetName == 'register1'
                                  ? c.emailController
                                  : c.sheetName == 'register2'
                                  ? c.nameController
                                  : c.emailController,
                              c.sheetName == 'register1'
                                  ? S.of(context).email
                                  : c.sheetName == 'register2'
                                  ? S.of(context).full_name
                                  : S.of(context).email,
                              false,
                              false,
                                  (val) {
                                if (c.sheetName == 'register1') {
                                  return c.validatorEmail(val!);
                                } else if (c.sheetName == 'register2') {
                                  return c.validatorName(val!);
                                } else {
                                  return c.validatorEmail(val!);
                                }
                              },
                              TextInputType.emailAddress,
                              null,
                              null,
                              textDirection: isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ),

                          if (c.sheetName == 'register2')
                            textFieldWidget(
                              c.userNameController,
                              S.of(context).userName,
                              false,
                              false,
                                  (val) {
                                return c.validatorUserName(val!);
                              },
                              TextInputType.name,
                              null,
                              null,
                              textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                            ),
                          if (c.sheetName == 'register2')
                            const SizedBox(
                              height: 15,
                            ),
                          if (c.sheetName == 'verifyLogin' ||
                              c.sheetName == 'verifyRegister')
                            const SizedBox(
                              height: 15,
                            ),
                          if (c.sheetName == 'verifyLogin' ||
                              c.sheetName == 'verifyRegister')
                            textClick(S.of(context).resend, false, () {
                              c.reSendOTP();
                            }, AppColors.blackTextColor, 3.5.w),
                          // Next Button
                          if (c.sheetName == 'Login' ||
                              c.sheetName == 'register1' ||
                              c.sheetName == 'register2')
                            c.statuesRequest == StatuesRequest.loading
                                ? loading(7.h)
                                : textClick(
                              S.of(context).next,
                              false,
                                  () {
                                if (c.formKey.currentState!.validate()) {
                                  if (c.sheetName == 'Login') {
                                    c.login();
                                  } else if (c.sheetName == 'register2') {
                                    c.updateSheet('register1');
                                  } else if (c.sheetName == 'register1') {
                                    c.register();
                                  }
                                }
                              },
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackColor,
                              3.7.w,
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          // Safe area bottom padding
                          SizedBox(
                              height: MediaQuery.of(context).padding.bottom > 0
                                  ? 8
                                  : 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}