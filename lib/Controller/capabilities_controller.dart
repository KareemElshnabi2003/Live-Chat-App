import 'dart:developer';

import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/auth_source.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';

class CapabilitiesController extends GetxController {
  var powers = <PowerModel>[].obs;
  var statuesRequest = StatuesRequest.none.obs;

  final AuthRemoteData _authRemoteData = AuthRemoteData(api: Get.put(Api()));

  Future<void> fetchUserPowers() async {
    try {
      statuesRequest.value = StatuesRequest.loading;
      final token = sharedPreferences!.getString("token") ?? "";
      if (token.isEmpty) {
        statuesRequest.value = StatuesRequest.unauthorizedException;
        Get.snackbar(
          S.of(Get.context!).error,
          S.of(Get.context!).unauthorizedError,
          backgroundColor: AppColors.redColor,
          colorText: AppColors.blackTextColor,
        );
        return;
      }

      var response = await _authRemoteData.getUserPowers();
      statuesRequest.value = handlingData(response);

      if (statuesRequest.value == StatuesRequest.success) {
        List<dynamic> responseData = response['data'] ?? [];
        powers.assignAll(
            responseData.map((e) => PowerModel.fromJson(e)).toList());
        log("User powers loaded: ${powers.length} items ${powers[0].active}");
      } else {
        _handleError(statuesRequest.value);
      }
    } catch (e) {
      statuesRequest.value = StatuesRequest.serverException;
      _handleError(statuesRequest.value);
      log("Error fetching user powers: $e");
    }
  }

  void _handleError(StatuesRequest status) {
    showUserFriendlyError(status);
  }

  @override
  void onInit() {
    fetchUserPowers();
    super.onInit();
  }
}