import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/DataSource/payment_source.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/PaymentWebViewPage.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';

class BottomSheetController extends GetxController {
  final RxList<String> chatsToPin = <String>[].obs;
  final RxList<UserChatModel> systemChats = <UserChatModel>[].obs;
  final RxString selectChatpIN = RxString('');
  RxDouble rotationAngle = 0.0.obs;
  String paymentMethod = "";
  RxBool isLoadingPayment = false.obs;
  RxBool isLoadingChats = false.obs;
  final RxList<Map<String, dynamic>> availableTimeSlots =
      <Map<String, dynamic>>[].obs;
  final RxList<String> selectedTimeSlots = <String>[].obs;
  RxBool isLoadingTimeSlots = false.obs;
  String selectedDate = "";

  // Image picker
  final ImagePicker _picker = ImagePicker();
  Rx<XFile?> adImage = Rx<XFile?>(null);

  // التعديل هنا: استخدام Get.find
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  final Api _api = Get.find<Api>();

  StatuesRequest statuesRequestChats = StatuesRequest.none;
  StatuesRequest statuesRequestTimeSlots = StatuesRequest.none;
  StatuesRequest statuesRequestPinChat = StatuesRequest.none;
  StatuesRequest statuesRequest = StatuesRequest.none;

  int currentPage = 1;
  final int perPage = 15;
  bool hasMoreChats = true;
  RxBool isLoadingMoreChats = false.obs;

  // Image picker methods
  Future<void> pickAdImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        adImage.value = image;
        log("Image selected: ${image.path}");
        update();
      }
    } catch (e) {
      log("Error picking image: $e");
      Get.snackbar(
        S.of(Get.context!).error,
        "Failed to pick image",
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  void removeAdImage() {
    adImage.value = null;
    log("Image removed");
    update();
  }

  Future<void> getSystemConversations({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMoreChats || isLoadingMoreChats.value) return;
        isLoadingMoreChats.value = true;
      } else {
        isLoadingChats.value = true;
        currentPage = 1;
        hasMoreChats = true;
      }

      statuesRequestChats = StatuesRequest.loading;
      update();

      String? token = sharedPreferences!.getString("token");
      var response = await _chatsRemoteData.getuserChats(
          page: currentPage, perPage: perPage, token: token ?? "");

      statuesRequestChats = handlingData(response);

      if (statuesRequestChats == StatuesRequest.success) {
        List responseBody = response['data'] ?? [];

        if (!loadMore) {
          systemChats.clear();
          chatsToPin.clear();
        }

        List<UserChatModel> newChats = responseBody
            .map((e) => UserChatModel.fromJson(e))
            .where(
              (element) =>
                  (element.status == "Public" || element.status == "Private") &&
                  element.user!.id.toString() ==
                      sharedPreferences!.getString("id"),
            )
            .toList();
        systemChats.addAll(newChats);
        chatsToPin.addAll(newChats.map((chat) => chat.name ?? ''));

        hasMoreChats = responseBody.length == perPage;
        if (hasMoreChats) {
          currentPage++;
        }

        log("System conversations loaded: ${systemChats.length} items (page: ${currentPage - 1})");
      } else {
        log("Failed to load system conversations: $statuesRequestChats");
        if (Get.context != null && !loadMore) {
          chatsToPin.addAll([
            S.of(Get.context!).chat_1,
            S.of(Get.context!).chat_2,
            S.of(Get.context!).chat_3
          ]);
        }
      }
    } catch (e) {
      log("Error loading system conversations: $e");
      if (Get.context != null && !loadMore) {
        chatsToPin.addAll([
          S.of(Get.context!).chat_1,
          S.of(Get.context!).chat_2,
          S.of(Get.context!).chat_3
        ]);
      }
    } finally {
      if (loadMore) {
        isLoadingMoreChats.value = false;
      } else {
        isLoadingChats.value = false;
      }
      update();
    }
  }

  Future<void> loadMoreChats() async {
    await getSystemConversations(loadMore: true);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              onSurface: AppColors.blackColor,
            ),
            dialogTheme:
                const DialogThemeData(backgroundColor: AppColors.whiteColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";

      dateController.text = formattedDate;
      log("📅 Date selected: $formattedDate");

      fetchAvailableTimeSlots(formattedDate);
      update();
    }
  }

  Future<void> fetchAvailableTimeSlots(String date) async {
    if (date.isEmpty || date.length < 8) {
      log("Invalid date format: $date");
      return;
    }
    try {
      isLoadingTimeSlots.value = true;
      statuesRequestTimeSlots = StatuesRequest.loading;
      availableTimeSlots.clear();
      selectedTimeSlots.clear();
      selectedDate = date;
      update();
      String formattedDate = _formatDateForAPI(date);
      log("Fetching time slots for date: $formattedDate");
      String? token = sharedPreferences!.getString("token");
      if (token == null || token.isEmpty) {
        log("No token found in sharedPreferences");
        statuesRequestTimeSlots = StatuesRequest.unauthorizedException;
        isLoadingTimeSlots.value = false;
        update();
        return;
      }
      var response = await _api.getData(
        "${AppApi.getAvailableTime}?date=$formattedDate",
      );
      var result = response.fold((l) => l, (r) => r);
      statuesRequestTimeSlots = handlingData(result);
      if (statuesRequestTimeSlots == StatuesRequest.success) {
        if (result['status'] == 'success' && result['data'] != null) {
          List<dynamic> timeSlotsList = result['data'];
          availableTimeSlots.addAll(timeSlotsList.map((slot) => {
                'hour': slot['hour'],
                'period': slot['period'],
                'time': slot['time'],
                'available': slot['available'] ?? false,
              }));
          log("Available time slots loaded: ${availableTimeSlots.length} slots for date $formattedDate");
          availableTimeSlots.sort((a, b) {
            int hourA = _convertTo24Hour(
                a['hour'] as int? ?? 0, a['period'] as String? ?? 'AM');
            int hourB = _convertTo24Hour(
                b['hour'] as int? ?? 0, b['period'] as String? ?? 'AM');
            return hourA.compareTo(hourB);
          });
        } else {
          log("API returned error: ${result['message'] ?? 'Unknown error'}");
          statuesRequestTimeSlots = StatuesRequest.serverError;
        }
      } else {
        if (statuesRequestTimeSlots == StatuesRequest.defaultException) {
          _showErrorSnackbar(
            S.of(Get.context!).errorPin,
          );
        }
        log("Failed to load time slots: $statuesRequestTimeSlots");
      }
    } catch (e) {
      log("Error fetching available time slots: $e");
      statuesRequestTimeSlots = StatuesRequest.serverError;
    } finally {
      isLoadingTimeSlots.value = false;
      update();
    }
  }

  int _convertTo24Hour(int hour, String period) {
    if (hour == 12 && period == 'AM') return 0;
    if (hour == 12 && period == 'PM') return 12;
    if (period == 'PM' && hour != 12) return hour + 12;
    return hour;
  }

  Future<void> pinConversation() async {
    try {
      isLoadingPayment.value = true;
      statuesRequestPinChat = StatuesRequest.loading;
      update();

      String? token = sharedPreferences!.getString("token");
      if (token == null || token.isEmpty) {
        log("No token found in sharedPreferences");
        statuesRequestPinChat = StatuesRequest.unauthorizedException;
        isLoadingPayment.value = false;
        update();
        return;
      }

      var selectedChat = getSelectedChat();
      if (selectedChat == null) {
        log("No chat selected");
        statuesRequestPinChat = StatuesRequest.serverError;
        isLoadingPayment.value = false;
        update();
        return;
      }

      var uri = Uri.parse(AppApi.pinChat);
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        "Accept": "application/json",
        "Lang": sharedPreferences!.getString("local") == "en" ? "en" : "ar",
        "Authorization": "Bearer $token",
      });

      request.fields['conversation_id'] = selectedChat.id.toString();
      request.fields['has_ad'] = (addAds == S.of(Get.context!).yes) ? '1' : '0';

      if (addAds == S.of(Get.context!).yes) {
        request.fields['ad_title'] = titleAdsController.text;
        request.fields['ad_link'] = descAdsController.text;
      }

      request.fields['pin_date'] = getFormattedSelectedDate();

      var pinHoursList = getSelectedTimeSlotsList();
      for (int i = 0; i < pinHoursList.length; i++) {
        request.fields['pin_hours[$i][hour]'] =
            pinHoursList[i]['hour'].toString();
        request.fields['pin_hours[$i][period]'] =
            pinHoursList[i]['period'].toString();
      }

      if (addAds == S.of(Get.context!).yes && adImage.value != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'ad_image',
          adImage.value!.path,
        );
        request.files.add(imageFile);
        log("Image added to request: ${adImage.value!.path}");
      }

      log("Request fields: ${request.fields}");
      log("Request files: ${request.files.length}");
      log("Request headers: ${request.headers}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      var result;
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        log("Error parsing response: $e");
        log("Raw response: ${response.body}");
        _showErrorSnackbar("Invalid server response");
        isLoadingPayment.value = false;
        return;
      }

      if (response.statusCode == 422) {
        log("Validation error (422): ${result.toString()}");
        String errorMessage = "Validation failed";

        if (result['message'] != null) {
          errorMessage = result['message'];
        }

        if (result['errors'] != null) {
          Map<String, dynamic> errors = result['errors'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else {
              errorMessages.add(value.toString());
            }
          });
          errorMessage = errorMessages.join('\n');
        }

        _showErrorSnackbar(errorMessage);
        statuesRequestPinChat = StatuesRequest.serverError;
        isLoadingPayment.value = false;
        update();
        return;
      }

      if (response.statusCode == 402) {
        log("Payment Required (402) - Response body: ${result.toString()}");
        _showErrorSnackbar(result['message']);
        statuesRequestPinChat = StatuesRequest.serverError;
        isLoadingPayment.value = false;
        update();
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (result['status'] == 'success') {
          log("Conversation pinned successfully: ${result['data']['id']}");

          if (Get.context != null) {
            Get.snackbar(
              S.of(Get.context!).success,
              S.of(Get.context!).succsesPin,
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.all(10),
              borderRadius: 25,
              colorText: AppColors.blackTextColor,
              snackPosition: SnackPosition.BOTTOM,
              snackStyle: SnackStyle.GROUNDED,
            );
          }
          Get.back(); // Close bottom sheet
          resetControllers();
          statuesRequestPinChat = StatuesRequest.success;
        } else {
          log("API returned error: ${result['message'] ?? 'Unknown error'}");
          statuesRequestPinChat = StatuesRequest.serverError;
          _showErrorSnackbar(result['message']);
        }
      } else if (response.statusCode == 403 || response.statusCode == 400) {
        log("Insufficient stars - go to payment");
        _showErrorSnackbar(S.of(Get.context!).errorBuyStars);

        try {
          final service = StarsPurchaseService();
          statuesRequest = StatuesRequest.loading;
          update();

          int currentStars =
              int.parse(sharedPreferences!.getString("stars") ?? "0");
          int requiredStars = calculateStarsForHours();
          int starsNeeded = requiredStars - currentStars;

          if (starsNeeded > 0) {
            final paymentResponse = await service.createPaymentUrl(
              numberOfStars: starsNeeded.toString(),
            );

            if (paymentResponse.isNotEmpty &&
                paymentResponse["checkout_url"] != null) {
              statuesRequest = StatuesRequest.none;
              final iframeUrl = paymentResponse["checkout_url"];
              Get.to(() => PaymentWebView(iframeUrl: iframeUrl));
            } else {
              Get.snackbar(
                "Error",
                paymentResponse["message"] ?? "Something went wrong",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        } catch (e) {
          log("Payment error: $e");
          Get.snackbar(
            "Error",
            e.toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        log("Failed to pin conversation: ${response.statusCode}");
        _showErrorSnackbar(result['message'] ?? "Failed to pin conversation");
      }
    } catch (e) {
      log("Error pinning conversation: $e");
      statuesRequestPinChat = StatuesRequest.serverError;
      _showErrorSnackbar(null);
    } finally {
      isLoadingPayment.value = false;
      update();
    }
  }

  void _showErrorSnackbar(String? message) {
    if (Get.context != null) {
      Get.snackbar(
        S.of(Get.context!).error,
        message ?? S.of(Get.context!).error,
        backgroundColor: AppColors.redColor,
        padding: const EdgeInsets.all(10),
        borderRadius: 30,
        colorText: AppColors.blackTextColor,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
        duration: const Duration(seconds: 4),
      );
    }
  }

  String _formatDateForAPI(String inputDate) {
    try {
      inputDate = inputDate.trim();

      if (inputDate.contains('-')) {
        List<String> parts = inputDate.split('-');
        if (parts.length == 3) {
          if (parts[0].length <= 2 && parts[2].length == 4) {
            String day = parts[0].padLeft(2, '0');
            String month = parts[1].padLeft(2, '0');
            String year = parts[2];
            String formatted = '$year-$month-$day';
            log("📅 Formatted date from DD-MM-YYYY: $inputDate -> $formatted");
            return formatted;
          } else if (parts[0].length == 4) {
            log("📅 Date already in API format: $inputDate");
            return inputDate;
          }
        }
      }

      if (inputDate.contains('/')) {
        List<String> parts = inputDate.split('/');
        if (parts.length == 3) {
          String year = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
          String month = parts[0].padLeft(2, '0');
          String day = parts[1].padLeft(2, '0');
          String formatted = '$year-$month-$day';
          log("📅 Formatted date from MM/DD/YYYY: $inputDate -> $formatted");
          return formatted;
        }
      }

      if (inputDate.length == 8 && int.tryParse(inputDate) != null) {
        String year = inputDate.substring(0, 4);
        String month = inputDate.substring(4, 6);
        String day = inputDate.substring(6, 8);
        String formatted = '$year-$month-$day';
        log("📅 Formatted date from YYYYMMDD: $inputDate -> $formatted");
        return formatted;
      }

      if (inputDate.length == 6 && int.tryParse(inputDate) != null) {
        String day = inputDate.substring(0, 2);
        String month = inputDate.substring(2, 4);
        String year = '20${inputDate.substring(4, 6)}';
        String formatted = '$year-$month-$day';
        log("📅 Formatted date from DDMMYY: $inputDate -> $formatted");
        return formatted;
      }

      log("⚠️ Using date as is: $inputDate");
      return inputDate;
    } catch (e) {
      log("❌ Error formatting date: $e");
      return inputDate;
    }
  }

  void toggleTimeSlotSelection(String timeSlot) {
    if (selectedTimeSlots.contains(timeSlot)) {
      selectedTimeSlots.remove(timeSlot);
      log("Removed time slot: $timeSlot");
    } else {
      selectedTimeSlots.add(timeSlot);
      log("Added time slot: $timeSlot");
    }
    update();
  }

  void selectAllAvailableTimeSlots() {
    selectedTimeSlots.clear();
    for (var slot in availableTimeSlots) {
      if (slot['available'] == true) {
        selectedTimeSlots.add(slot['time']);
      }
    }
    log("Selected all available time slots: ${selectedTimeSlots.length}");
    update();
  }

  void clearTimeSlotSelections() {
    selectedTimeSlots.clear();
    log("Cleared all time slot selections");
    update();
  }

  void clearAvailableTimeSlots() {
    availableTimeSlots.clear();
    selectedTimeSlots.clear();
    selectedDate = "";
    statuesRequestTimeSlots = StatuesRequest.none;
    log("Cleared available time slots");
    update();
  }

  int getAvailableTimeSlotsCount() {
    return availableTimeSlots.where((slot) => slot['available'] == true).length;
  }

  int getSelectedTimeSlotsCount() {
    return selectedTimeSlots.length;
  }

  List<Map<String, dynamic>> getAvailableTimeSlotsList() {
    return availableTimeSlots
        .where((slot) => slot['available'] == true)
        .toList();
  }

  List<Map<String, dynamic>> getSelectedTimeSlotsList() {
    return availableTimeSlots
        .where((slot) => selectedTimeSlots.contains(slot['time']))
        .toList();
  }

  changeVal(String? val) {
    selectChatpIN.value = val ?? '';
    clearAvailableTimeSlots();
    dateController.clear();
    log("Changed chat selection to: ${selectChatpIN.value}");
    update();
  }

  String addAds = S.of(Get.context!).no;

  changeAds(String? val) {
    addAds = val == S.of(Get.context!).yes
        ? S.of(Get.context!).yes
        : S.of(Get.context!).no;
    rotationAngle.value = val == S.of(Get.context!).yes ? 0.5 : 0.0;

    if (addAds == S.of(Get.context!).no) {
      removeAdImage();
    }

    log("Changed ads option to: $addAds");
    update();
  }

  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController numOfStarsController =
      TextEditingController();
  late final TextEditingController titleAdsController = TextEditingController();
  late final TextEditingController descAdsController = TextEditingController();
  late final TextEditingController walletNumController =
      TextEditingController();
  late final TextEditingController dateController = TextEditingController();
  late final TextEditingController timeController = TextEditingController();
  late final TextEditingController timeToPinController =
      TextEditingController();

  String sheetPINChatName = 'firstPage';
  String sheetMarket = "firstPage";
  String sheetBuyMarket = "firstPage";
  RxDouble cardRotation = 0.0.obs;

  void rotateCard135() {
    cardRotation.value = -1 / 8;
  }

  void rotateCardtoMain() {
    cardRotation.value = 0;
  }

  void updatePINChatSheet(String newName) {
    sheetPINChatName = newName;
    log("Updated PIN chat sheet to: $newName");
    update();
  }

  void updateMarketSheet(String newName) {
    sheetMarket = newName;
    log("Updated market sheet to: $newName");
    update();
  }

  void updateMarketBuySheet(String newName) {
    sheetBuyMarket = newName;
    log("Updated market buy sheet to: $newName");
    update();
  }

  void setLoadingPayment(bool loading) {
    isLoadingPayment.value = loading;
    log("Set loading payment: $loading");
    update();
  }

  void resetControllers() {
    nameController.clear();
    numOfStarsController.clear();
    walletNumController.clear();
    dateController.clear();
    titleAdsController.clear();
    descAdsController.clear();
    timeController.clear();
    timeToPinController.clear();
    adImage.value = null;
    clearAvailableTimeSlots();
    sheetBuyMarket = "firstPage";
    sheetPINChatName = 'firstPage';
    sheetMarket = "firstPage";
    addAds = "No";
    rotateCardtoMain();
    paymentMethod = "";
    log("Reset all controllers and data");
    update();
  }

  int calculateStarsForHours() {
    return getSelectedTimeSlotsCount() * 150;
  }

  bool validateStarsInput() {
    if (numOfStarsController.text.isEmpty) return false;
    final stars = int.tryParse(numOfStarsController.text);
    return stars != null && stars > 0 && stars <= 10000;
  }

  bool validateDateInput() {
    return dateController.text.isNotEmpty && dateController.text.length >= 8;
  }

  bool validateTimeSlotSelection() {
    return selectedTimeSlots.isNotEmpty && validateDateInput();
  }

  bool validateBasicInput() {
    return selectChatpIN.value.isNotEmpty;
  }

  bool validateAdsInput() {
    if (addAds == S.of(Get.context!).no) return true;
    return titleAdsController.text.isNotEmpty &&
        descAdsController.text.isNotEmpty &&
        adImage.value != null;
  }

  bool validateAllInputs() {
    if (addAds == S.of(Get.context!).no) {
      return validateBasicInput() &&
          validateDateInput() &&
          validateTimeSlotSelection();
    } else {
      return validateBasicInput() &&
          validateDateInput() &&
          validateTimeSlotSelection() &&
          validateAdsInput();
    }
  }

  String getSelectedTimeSlotsString() {
    return selectedTimeSlots.join(', ');
  }

  String getFormattedSelectedDate() {
    if (selectedDate.isEmpty) return "";
    return _formatDateForAPI(selectedDate);
  }

  Map<String, dynamic> getPinChatData() {
    return {
      'chat_id': getSelectedChat()?.id ?? '',
      'chat_name': selectChatpIN.value,
      'selected_date': getFormattedSelectedDate(),
      'selected_time_slots': selectedTimeSlots,
      'time_slots_count': selectedTimeSlots.length,
      'add_ads': addAds,
      'ad_title': addAds == "Yes" ? titleAdsController.text : '',
      'ad_link': addAds == "Yes" ? descAdsController.text : '',
      'ad_image_path': adImage.value?.path ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  UserChatModel? getSelectedChat() {
    if (selectChatpIN.value.isEmpty) return null;
    try {
      return systemChats.firstWhere((chat) => chat.name == selectChatpIN.value);
    } catch (e) {
      log("No chat found with name: ${selectChatpIN.value}");
      return null;
    }
  }

  void refreshTimeSlots() {
    if (dateController.text.isNotEmpty) {
      fetchAvailableTimeSlots(dateController.text);
    }
  }

  void onDateChanged(String newDate) {
    if (newDate.isNotEmpty && newDate.length >= 8) {
      if (selectedDate != newDate) {
        clearTimeSlotSelections();
      }
      fetchAvailableTimeSlots(newDate);
    } else if (newDate.isEmpty) {
      clearAvailableTimeSlots();
    }
  }

  void clearDate() {
    dateController.clear();
    clearAvailableTimeSlots();
    update();
    log("📅 Date cleared");
  }

  @override
  void onInit() {
    super.onInit();
    log("BottomSheetController initialized");
    getSystemConversations();
  }

  @override
  void onClose() {
    log("BottomSheetController closing - disposing controllers");
    nameController.dispose();
    numOfStarsController.dispose();
    titleAdsController.dispose();
    descAdsController.dispose();
    walletNumController.dispose();
    dateController.dispose();
    timeController.dispose();
    timeToPinController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    log("BottomSheetController ready");
  }
}
