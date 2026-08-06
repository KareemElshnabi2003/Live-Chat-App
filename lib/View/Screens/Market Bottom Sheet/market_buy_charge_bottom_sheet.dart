// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/Controller/bottm_sheet__controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/DataSource/payment_source.dart';
import 'package:live_chat/Data/DataSource/send_stars_source.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_success_send_stars.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_field_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';

import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

// Models for payment data
class PaymentOption {
  final int stars;
  final int price;

  PaymentOption({required this.stars, required this.price});

  factory PaymentOption.fromJson(Map<String, dynamic> json) {
    return PaymentOption(
      stars: json['stars'],
      price: json['price'],
    );
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final Map<String, dynamic> data;

  PaymentMethod({required this.id, required this.name, required this.data});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}

// Helper function to get the appropriate label based on payment method
String _getPaymentAddressLabel(String paymentMethod) {
  final lowerMethod = paymentMethod.toLowerCase();

  if (lowerMethod.contains('vodafone') || lowerMethod.contains('etisalat')) {
    return 'Phone Number';
  } else if (lowerMethod.contains('instapay')) {
    return 'IPN (InstaPay Number)';
  } else {
    return 'Payment Address/Number';
  }
}

// Helper function to get the appropriate keyboard type
TextInputType _getPaymentAddressKeyboardType(String paymentMethod) {
  final lowerMethod = paymentMethod.toLowerCase();

  if (lowerMethod.contains('vodafone') ||
      lowerMethod.contains('etisalat') ||
      lowerMethod.contains('instapay')) {
    return TextInputType.number;
  } else {
    return TextInputType.text;
  }
}

showBottomSheetMarketBuyChargeWidget({context}) {
  Get.put(BottomSheetController());
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  StatuesRequest statuesRequest = StatuesRequest.none;

  // Payment flow state
  List<PaymentOption> paymentOptions = [];
  List<PaymentOption> selectedOptions = [];
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  File? selectedImage;
  int totalStars = 0;
  int totalPrice = 0;

  // Controller for payment address field
  final TextEditingController paymentAddressController =
      TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (context) => GetBuilder<BottomSheetController>(
      builder: (c) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: c.sheetBuyMarket == "sendStarsPage"
              ? 45.h
              : c.sheetBuyMarket == "paymentOptionsPage"
                  ? 75.h
                  : c.sheetBuyMarket == "paymentMethodsPage"
                      ? 70.h
                      : c.sheetBuyMarket == "uploadReceiptPage"
                          ? 75.h
                          : 55.h,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 70,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                ),
                Container(
                  padding: EdgeInsets.only(
                    right: 4.w,
                    left: 4.w,
                    top: 4.w,
                  ),
                  width: 100.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back/Close button
                      Row(
                        mainAxisAlignment: isRtl
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          textClick(
                            c.sheetBuyMarket != "firstPage"
                                ? S.of(context).back
                                : S.of(context).close,
                            true,
                            () {
                              if (c.sheetBuyMarket == "firstPage") {
                                Get.back();
                              } else if (c.sheetBuyMarket == "sendStarsPage") {
                                c.updateMarketBuySheet("firstPage");
                              } else if (c.sheetBuyMarket ==
                                  "paymentOptionsPage") {
                                c.updateMarketBuySheet("firstPage");
                              } else if (c.sheetBuyMarket ==
                                  "paymentMethodsPage") {
                                c.updateMarketBuySheet("paymentOptionsPage");
                              } else if (c.sheetBuyMarket ==
                                  "uploadReceiptPage") {
                                c.updateMarketBuySheet("paymentMethodsPage");
                              }
                            },
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                            3.5.w,
                          ),
                        ],
                      ),

                      // First Page - Main Menu
                      if (c.sheetBuyMarket == "firstPage") ...[
                        SizedBox(
                          height: 40.w,
                          width: 100.w,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 25.w,
                                right: 20.w,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AppImages.starFillImg),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 25.w,
                                left: 18.w,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AppImages.starImg),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        textNormal(
                          S.of(context).buyOrSendStars,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                        SizedBox(height: 3.h),
                        Button(
                          text: S.of(context).send,
                          ontap: () {
                            c.updateMarketBuySheet("sendStarsPage");
                          },
                        ),
                        SizedBox(height: 1.5.h),
                        Button(
                          text: S.of(context).purchase,
                          ontap: () async {
                            try {
                              statuesRequest = StatuesRequest.loading;
                              c.update();

                              final service = StarsPurchaseService();
                              final response =
                                  await service.getPaymentOptions();

                              if (response != null && response.isNotEmpty) {
                                paymentOptions = (response as List)
                                    .map((e) => PaymentOption.fromJson(e))
                                    .toList();
                                selectedOptions.clear();
                                statuesRequest = StatuesRequest.none;
                                c.updateMarketBuySheet("paymentOptionsPage");
                              } else {
                                statuesRequest = StatuesRequest.none;
                                Get.snackbar(
                                  S.of(context).genericError,
                                  S.of(context).somethingWentWrong,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } catch (e) {
                              statuesRequest = StatuesRequest.none;
                              Get.snackbar(
                                S.of(context).genericError,
                                e.toString(),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ],

                      // Send Stars Page
                      if (c.sheetBuyMarket == "sendStarsPage") ...[
                        SizedBox(
                          height: 40.w,
                          width: 100.w,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 25.w,
                                right: 20.w,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AppImages.starFillImg),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 25.w,
                                left: 18.w,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AppImages.starImg),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        textNormal(
                          S.of(context).buyOrSendStars,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 6.h,
                          child: textFieldWidget(
                            c.nameController,
                            S.of(context).email,
                            false,
                            false,
                            null,
                            TextInputType.text,
                            null,
                            null,
                            textDirection:
                                isRtl ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 6.h,
                          child: textFieldWidget(
                            c.numOfStarsController,
                            S.of(context).numberOfStars,
                            false,
                            false,
                            null,
                            TextInputType.number,
                            null,
                            null,
                            textDirection:
                                isRtl ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Button(
                          text: S.of(context).send,
                          ontap: () async {
                            final starsService = StarsService();
                            final response = await starsService.sendStars(
                              c.nameController.text,
                              c.numOfStarsController.text,
                            );
                            Get.back();
                            if (response['status'] == 'success') {
                              messageSuccessSendStars(context);
                              c.sheetBuyMarket = "firstPage";
                            } else {
                              Get.snackbar(
                                S.of(context).error,
                                response['message'],
                                backgroundColor:
                                    AppColors.redColor.withOpacity(0.95),
                                colorText: AppColors.whiteColor,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ],

                      // Payment Options Page
                      if (c.sheetBuyMarket == "paymentOptionsPage") ...[
                        SizedBox(height: 2.h),
                        textNormal(
                          S.of(context).selectStarsPackages,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          4.w,
                          FontWeight.w600,
                        ),
                        SizedBox(height: 2.h),
                        // ignore: sized_box_for_whitespace
                        Container(
                          height: 45.h,
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 3.w,
                              mainAxisSpacing: 2.h,
                              childAspectRatio: 2,
                            ),
                            itemCount: paymentOptions.length,
                            itemBuilder: (context, index) {
                              final option = paymentOptions[index];
                              final isSelected =
                                  selectedOptions.contains(option);

                              return GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    selectedOptions.remove(option);
                                    totalStars -= option.stars;
                                    totalPrice -= option.price;
                                  } else {
                                    selectedOptions.add(option);
                                    totalStars += option.stars;
                                    totalPrice += option.price;
                                  }
                                  c.update();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                            .withOpacity(0.3)
                                        : (pref!
                                            ? Colors.grey.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      textNormal(
                                        "${option.stars} Stars",
                                        pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                        3.5.w,
                                        FontWeight.w600,
                                      ),
                                      SizedBox(height: 0.5.h),
                                      textNormal(
                                        "${option.price} EGP",
                                        pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                        3.w,
                                        FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (selectedOptions.isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: pref!
                                  ? Colors.grey.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                textNormal(
                                  S.of(context).totalStars(totalStars),
                                  pref!
                                      ? AppColors.whiteColor
                                      : AppColors.blackTextColor,
                                  3.5.w,
                                  FontWeight.w600,
                                ),
                                textNormal(
                                  "$totalPrice EGP",
                                  AppColors.primaryColor,
                                  3.5.w,
                                  FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 2.h),
                        Button(
                          text: S.of(Get.context!).next,
                          ontap: selectedOptions.isEmpty
                              ? null
                              : () async {
                                  try {
                                    statuesRequest = StatuesRequest.loading;
                                    c.update();

                                    final service = StarsPurchaseService();
                                    final response =
                                        await service.getPaymentMethods();

                                    if (response != null &&
                                        response['status'] == 'success' &&
                                        response['data'] != null) {
                                      paymentMethods = (response['data']
                                              as List)
                                          .map((e) => PaymentMethod.fromJson(e))
                                          .toList();
                                      selectedPaymentMethod = null;
                                      statuesRequest = StatuesRequest.none;
                                      c.updateMarketBuySheet(
                                          "paymentMethodsPage");
                                    } else {
                                      statuesRequest = StatuesRequest.none;
                                      Get.snackbar(
                                        S.of(context).genericError,
                                        S.of(context).somethingWentWrong,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  } catch (e) {
                                    statuesRequest = StatuesRequest.none;
                                    Get.snackbar(
                                      S.of(context).genericError,
                                      e.toString(),
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                        ),
                      ],

                      // Payment Methods Page
                      if (c.sheetBuyMarket == "paymentMethodsPage") ...[
                        SizedBox(height: 2.h),
                        textNormal(
                          S.of(context).selectPaymentMethod,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          4.w,
                          FontWeight.w600,
                        ),
                        SizedBox(height: 2.h),
                        // ignore: sized_box_for_whitespace
                        Container(
                          height: 45.h,
                          child: ListView.builder(
                            itemCount: paymentMethods.length,
                            itemBuilder: (context, index) {
                              final method = paymentMethods[index];
                              final isSelected =
                                  selectedPaymentMethod == method;

                              return GestureDetector(
                                onTap: () {
                                  selectedPaymentMethod = method;
                                  c.update();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 2.h),
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                            .withOpacity(0.3)
                                        : (pref!
                                            ? Colors.grey.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      textNormal(
                                        method.name,
                                        pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                        4.w,
                                        FontWeight.w600,
                                      ),
                                      SizedBox(height: 1.h),
                                      ...method.data.entries.map((entry) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 0.5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              textNormal(
                                                "${entry.key}:",
                                                pref!
                                                    ? AppColors.whiteColor
                                                        .withOpacity(0.7)
                                                    : AppColors.blackTextColor
                                                        .withOpacity(0.7),
                                                3.w,
                                                FontWeight.w400,
                                              ),
                                              Expanded(
                                                child: textNormal(
                                                  entry.value.toString(),
                                                  pref!
                                                      ? AppColors.whiteColor
                                                      : AppColors
                                                          .blackTextColor,
                                                  3.w,
                                                  FontWeight.w500,
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        // ignore: unnecessary_to_list_in_spreads
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Button(
                          text: "Next",
                          ontap: selectedPaymentMethod == null
                              ? null
                              : () {
                                  // Clear the payment address field when navigating
                                  paymentAddressController.clear();
                                  c.updateMarketBuySheet("uploadReceiptPage");
                                },
                        ),
                      ],

                      // Upload Receipt Page
                      if (c.sheetBuyMarket == "uploadReceiptPage") ...[
                        SizedBox(height: 2.h),
                        textNormal(
                          S.of(context).uploadPaymentReceipt,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          4.w,
                          FontWeight.w600,
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: pref!
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              textNormal(
                                S.of(context).paymentDetails,
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                3.5.w,
                                FontWeight.w600,
                              ),
                              SizedBox(height: 1.h),
                              textNormal(
                                S.of(context).starsCount(totalStars),
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                3.w,
                                FontWeight.w400,
                              ),
                              textNormal(
                                S.of(context).priceAmount(totalPrice),
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                3.w,
                                FontWeight.w400,
                              ),
                              textNormal(
                                "${S.of(context).paymentMethod}: ${selectedPaymentMethod?.name}",
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                3.w,
                                FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Payment Address TextField
                        SizedBox(
                          height: 6.h,
                          child: textFieldWidget(
                            paymentAddressController,
                            _getPaymentAddressLabel(
                                selectedPaymentMethod?.name ?? ""),
                            false,
                            false,
                            null,
                            _getPaymentAddressKeyboardType(
                                selectedPaymentMethod?.name ?? ""),
                            null,
                            null,
                            textDirection:
                                isRtl ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              selectedImage = File(image.path);
                              c.update();
                            }
                          },
                          child: Container(
                            height: 20.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: pref!
                                  ? Colors.grey.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 10.w,
                                        color: pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                      ),
                                      SizedBox(height: 1.h),
                                      textNormal(
                                        S.of(context).tapToUploadReceipt,
                                        pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                        3.w,
                                        FontWeight.w400,
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        statuesRequest == StatuesRequest.loading
                            ? loading(5.h)
                            : Button(
                                text: S.of(context).finish,
                                ontap: (selectedImage == null ||
                                        paymentAddressController.text
                                            .trim()
                                            .isEmpty)
                                    ? null
                                    : () async {
                                        try {
                                          statuesRequest =
                                              StatuesRequest.loading;
                                          c.update();

                                          final service =
                                              StarsPurchaseService();

                                          // Use the user-entered payment address
                                          String paymentAddress =
                                              paymentAddressController.text
                                                  .trim();

                                          final response =
                                              await service.submitManualPayment(
                                            image: selectedImage!,
                                            price: totalPrice,
                                            paymentAddress: paymentAddress,
                                            paymentType:
                                                selectedPaymentMethod!.name,
                                            stars: totalStars,
                                          );

                                          statuesRequest = StatuesRequest.none;
                                          Get.back();

                                          if (response != null &&
                                              response['status'] == 'success') {
                                            Get.dialog(AlertDialog(
                                              backgroundColor: pref!
                                                  ? AppColors.blackColor
                                                  : AppColors.whiteColor,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 24),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size:
                                                        60, // Fixed reasonable size
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    S
                                                        .of(context)
                                                        .orderUnderReview,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: pref!
                                                          ? AppColors.whiteColor
                                                          : AppColors
                                                              .blackTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    c.sheetBuyMarket =
                                                        "firstPage";
                                                  },
                                                  child: Text(
                                                    S.of(context).ok,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ));
                                          } else {
                                            Get.snackbar(
                                              S.of(context).genericError,
                                              response?['message'] ??
                                                  S
                                                      .of(context)
                                                      .somethingWentWrong,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } catch (e) {
                                          statuesRequest = StatuesRequest.none;
                                          Get.snackbar(
                                            S.of(context).genericError,
                                            e.toString(),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                              ),
                      ],

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
