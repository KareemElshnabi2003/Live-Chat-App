// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/member_of_chat_model.dart';
import 'package:live_chat/Data/Model/theme_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CreateChatController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());

  List<ThemeModel> themes = [];
  UserChatModel? userChatModel;
  File? fileImgChat;
  File? fileImgBgChat;
  bool isCustomThemeSelected = false;

  final TextEditingController nameController = TextEditingController();
  String selectedPrivacy = '';
  String selectedCanChat = '';
  String selectedFormat = '';
  String? themeId;
  List customThemeImages = [];
  List<Map<String, dynamic>> chatAdmin = [];
  List<MemberOfChatModel> members = [];

  final List<String> privacyOptions = [
    S.of(Get.context!).private,
    S.of(Get.context!).public
  ];
  final List<String> canChatOption = [
    S.of(Get.context!).yes,
    S.of(Get.context!).no
  ];
  final List<String> managerOptions = [
    S.of(Get.context!).user_a,
    S.of(Get.context!).user_b,
    S.of(Get.context!).user_c
  ];

  @override
  void onInit() {
    super.onInit();
    print(">>>>>>>>>😍 ${sharedPreferences!.getString("deviceToken")}");
   if(sharedPreferences!.getString("token")!="null"&&sharedPreferences!.getString("token")!=null){
     getThemes();
     loadCustomThemes();
   }

  }

  chooseTheme(id) {
    themeId = id;
    isCustomThemeSelected = false;
    selectedFormat = '';
    fileImgBgChat = null;
    update();
  }

  changeToCustom(String customThemePath) {
    if (File(customThemePath).existsSync()) {
      selectedFormat = customThemePath;
      fileImgBgChat = File(customThemePath);
      themeId = null;
      isCustomThemeSelected = true;
    }
    update();
  }

  chooseCan(value) {
    selectedCanChat = value ?? '';
    update();
  }

  choosePrivacy(value) {
    selectedPrivacy = value ?? '';
    update();
  }

  Future<void> loadCustomThemes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final customThemesDir = Directory('${directory.path}/custom_themes');

      if (await customThemesDir.exists()) {
        final files = customThemesDir
            .listSync()
            .where((file) =>
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png'))
            .map((file) => file.path)
            .toList();

        customThemeImages.assignAll(files);
      }
    } catch (e) {
      log('Error loading custom themes: $e');
    }
    update();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        fileImgChat = File(image.path);
        log("Original image size: ${fileImgChat!.lengthSync()} bytes");
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          fileImgChat!.path,
          "${fileImgChat!.path}_compressed.jpg",
          quality: 60,
        );
        if (compressedFile != null) {
          final compressedSize = await compressedFile.length();
          fileImgChat = File(compressedFile.path);
          log("Compressed image size: $compressedSize bytes");
        } else {
          log("Compression failed: compressedFile is null");
        }
      }
    } catch (e) {
      log("Error during image picking or compression: $e");
      Get.snackbar(
        S.of(Get.context!).error,
        S.of(Get.context!).error_picking_image,
      );
    }
    update();
  }

  Future<void> addCustomTheme() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final customThemesDir = Directory('${directory.path}/custom_themes');

        if (!await customThemesDir.exists()) {
          await customThemesDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(image.path);
        final fileName = 'custom_theme_$timestamp$extension';
        final newPath = path.join(customThemesDir.path, fileName);

        fileImgBgChat = await File(image.path).copy(newPath);
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          fileImgBgChat!.path,
          "${fileImgBgChat!.path}_compressed.jpg",
          quality: 60,
        );
        if (compressedFile != null) {
          final compressedSize = await compressedFile.length();
          fileImgBgChat = File(compressedFile.path);
          log("Compressed image size: $compressedSize bytes");
        } else {
          log("Compression failed: compressedFile is null");
        }

        if (fileImgBgChat != null && await fileImgBgChat!.exists()) {
          customThemeImages.add(newPath);
          selectedFormat = newPath;
          themeId = null;
          isCustomThemeSelected = true;

          Get.snackbar(
            S.of(Get.context!).success,
            'Custom theme added successfully',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        S.of(Get.context!).error,
        'Error adding custom theme: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
    update();
  }

  Future<void> deleteCustomTheme(String customThemePath) async {
    try {
      if (File(customThemePath).existsSync()) {
        await File(customThemePath).delete();
        customThemeImages.remove(customThemePath);

        if (selectedFormat == customThemePath) {
          selectedFormat = '';
          fileImgBgChat = null;
          isCustomThemeSelected = false;
        }

        Get.snackbar(
          S.of(Get.context!).success,
          'Custom theme deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        S.of(Get.context!).error,
        'Error deleting custom theme: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
    update();
  }

  getThemes() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getThems(
     );
    log("response ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      if (response['code'] == 401) {
      } else {
        List responseBody = response['data'];
        themes.addAll(responseBody.map(
          (e) => ThemeModel.fromJson(e),
        ));
      }
    }else{
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  Future<File> compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      "${file.path}_compressed.jpg",
      quality: 70,
    );
    log("size :::::::::: ${file.length()}");
    return File(compressedFile!.path);
  }

  void createChat() async {
    bool hasTheme = themeId != null && themeId!.isNotEmpty;
    bool hasCustomTheme = isCustomThemeSelected &&
        selectedFormat.isNotEmpty &&
        fileImgBgChat != null &&
        fileImgBgChat!.existsSync();

    if (nameController.text.isEmpty ||
        selectedPrivacy.isEmpty ||
        (!hasTheme && !hasCustomTheme)) {
      Get.snackbar(S.of(Get.context!).error, S.of(Get.context!).fillAllFields);
      return;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.createGeneralChat(
        accept: selectedCanChat == S.of(Get.context!).yes ? 1 : 0,
        imgChat: fileImgChat,
        name: nameController.text,
        status: selectedPrivacy == S.of(Get.context!).public ? 1 : 0,
        them: hasCustomTheme ? fileImgBgChat : null,
        themeID: themeId == null ? "null" : int.parse(themeId!),
       );

    log("response ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      userChatModel = UserChatModel.fromJson(responseBody);
      Get.snackbar(
        S.of(Get.context!).success,
        S.of(Get.context!).creating_chat,
      );
      Get.to(
        () => ChatView(
          isGust: false,
          isPin: false,
          userChatModel: userChatModel,
        ),
        arguments: {"chatId": userChatModel!.id},
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
                showUserFriendlyError(statuesRequest);

    }

    update();
  }

  void toggleAdminSelection(MemberOfChatModel member) {
    final memberId = member.id.toString();
    final existingIndex =
        chatAdmin.indexWhere((admin) => admin["chat_admin_id"] == memberId);

    if (existingIndex != -1) {
      chatAdmin.removeAt(existingIndex);
    } else {
      chatAdmin.add({
        "chat_admin_id": memberId,
      });
    }
    update();
  }

  bool isAdminSelected(MemberOfChatModel member) {
    return chatAdmin
        .any((admin) => admin["chat_admin_id"] == member.id.toString());
  }

  void deleteChat() async {
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.deleteChat(
        chatId: userChatModel!.id,
     );

    log("response ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      Get.snackbar(
        S.of(Get.context!).success,
        S.of(Get.context!).delete,
      );
      Get.offAll(
        () => const HomeView(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {          showUserFriendlyError(statuesRequest);
}
    update();
  }
}
