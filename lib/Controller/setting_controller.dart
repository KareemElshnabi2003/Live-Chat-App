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

class SettingChatController extends GetxController {
  // التعديل هنا: استخدام Get.find
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.find<Api>());

  StatuesRequest statuesRequest = StatuesRequest.none;
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

  List<MemberOfChatModel> memmbersRequests = [];
  int currentMembersPage = 1;
  bool isLoadingMoreMembers = false;
  bool hasMoreMembers = true;

  Future<void> loadMoreMembers() async {
    if (!hasMoreMembers || isLoadingMoreMembers) return;

    await getMembers(page: currentMembersPage, loadMore: true);
  }

  sendFriendRequest({required friendID}) async {
    var response = await _chatsRemoteData.sendFriendRequest(
        friendId: friendID);

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      getMembers();
    } else {}          showUserFriendlyError(statuesRequest);

    update();
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
      List responseBody = response['data'];
      themes.addAll(responseBody.map(
            (e) => ThemeModel.fromJson(e),
      ));
    } else{          showUserFriendlyError(statuesRequest);
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

  void updateChat() async {
    bool hasCustomTheme = isCustomThemeSelected &&
        selectedFormat.isNotEmpty &&
        fileImgBgChat != null &&
        fileImgBgChat!.existsSync();

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.updateGeneralChat(
        chatID: userChatModel!.id,
        chatAdmins: chatAdmin,
        accept: selectedCanChat == ''
            ? userChatModel!.accept
            : selectedCanChat == S.of(Get.context!).yes
            ? 0
            : 1,
        imgChat: fileImgChat,
        name: nameController.text == "null"
            ? userChatModel!.name
            : nameController.text,
        status: selectedPrivacy == ''
            ? userChatModel!.status == "Public"
            ? 1
            : 0
            : selectedPrivacy == S.of(Get.context!).public
            ? 1
            : 0,
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
      Get.off(
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
    } else{          showUserFriendlyError(statuesRequest);
}
    update();
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

  List<String> adminIds = [];

  @override
  void onInit() {
    super.onInit();
    userChatModel = Get.arguments['chatModel'];
    _initializeAdminIds();
    getMembers();
    nameController.text = userChatModel!.name!;
    if(sharedPreferences!.getString("token")!=null&&sharedPreferences!.getString("token")!="null")getThemes();
    loadCustomThemes();
  }

  void _initializeAdminIds() {
    adminIds.clear();
    if (userChatModel?.chatAdmins != null) {
      adminIds = userChatModel!.chatAdmins!
          .map((admin) => admin.chatAdminId.toString())
          .toList();
    }

    chatAdmin.clear();
    for (String adminId in adminIds) {
      chatAdmin.add({"chat_admin_id": adminId});
    }
  }

  getMembers({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      members.clear();
      memmbersRequests.clear();
      currentMembersPage = 1;
      hasMoreMembers = true;
    }

    if (isLoadingMoreMembers || !hasMoreMembers) return;

    if (loadMore) {
      isLoadingMoreMembers = true;
    } else {
      statuesRequest = StatuesRequest.loading;
    }

    update();

    var response = await _chatsRemoteData.getMemberOfChat(
      perPage: 10,
      page: currentMembersPage,
      chatId: userChatModel!.id,

    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];

      if (responseBody.isEmpty) {
        hasMoreMembers = false;
      } else {
        List<MemberOfChatModel> newMembers =
        responseBody.map((e) => MemberOfChatModel.fromJson(e)).toList();

        List<MemberOfChatModel> acceptedMembers = newMembers
            .where(
                (element) => (element.requestStatus != "Waiting_for_acceptance"&&element.isGuest!=true))
            .toList();

        List<MemberOfChatModel> pendingRequests = newMembers
            .where(
                (element) => element.requestStatus == "Waiting_for_acceptance")
            .toList();

        if (loadMore) {
          members.addAll(acceptedMembers);
          memmbersRequests.addAll(pendingRequests);
        } else {
          members.addAll(acceptedMembers);
          memmbersRequests.addAll(pendingRequests);
        }

        currentMembersPage++;
        _syncChatAdminWithCurrentMembers();
      }
    } else {
      hasMoreMembers = false;
                showUserFriendlyError(statuesRequest);

    }

    isLoadingMoreMembers = false;
    update();
  }

  void _syncChatAdminWithCurrentMembers() {
    chatAdmin.clear();
    for (var member in members) {
      if (adminIds.contains(member.id.toString())) {
        chatAdmin.add({"chat_admin_id": member.id.toString()});
      }
    }
  }

  bool isAdminSelected(MemberOfChatModel member) {
    return adminIds.contains(member.id.toString()) ||
        chatAdmin
            .any((admin) => admin["chat_admin_id"] == member.id.toString());
  }

  void toggleAdminSelection(MemberOfChatModel member) {
    final memberId = member.id.toString();
    final existingIndex =
    chatAdmin.indexWhere((admin) => admin["chat_admin_id"] == memberId);

    if (existingIndex != -1) {
      chatAdmin.removeAt(existingIndex);
      adminIds.remove(memberId);
    } else {
      chatAdmin.add({"chat_admin_id": memberId});
      if (!adminIds.contains(memberId)) {
        adminIds.add(memberId);
      }
    }
    update();
  }
}