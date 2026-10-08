// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/market_source.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'dart:convert';
import 'package:live_chat/main.dart';

class MarketController extends GetxController {
  RxList<PowerModel> storePowers = <PowerModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var errorMessage = ''.obs;
  var numOfStars = 0.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var perPage = 20.obs;
  var hasMoreData = true.obs;

  @override
  void onInit() {
    fetchUserProfile();
    fetchStorePowers();
    super.onInit();
  }

  Future<void> fetchUserProfile() async {
    try {
      final token = sharedPreferences!.getString("token");
      if (token == null) {
        errorMessage('No authentication token found');
        return;
      }

      final response = await http.get(
        Uri.parse(AppApi.getProfileUrl),
        headers: {
          "Accept": "application/json",
          "Lang": sharedPreferences!.getString("local") == "en" ? "en" : "ar",
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          log(jsonData['data']['number_of_stars'].toString());
          numOfStars.value = jsonData['data']['number_of_stars'] ?? 0;
          String power = jsonEncode(jsonData['data']['user_power']);
          sharedPreferences!.setString("powermodel", power);
          sharedPreferences!.setString(
              "stars", jsonData['data']["number_of_stars"].toString());
        } else {
          errorMessage(jsonData['message'] ?? 'Failed to load profile data');
        }
      } else {
        errorMessage('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error fetching profile: $e');
    }
  }

  Future<void> fetchStorePowers({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoading(true);
      }

      errorMessage('');

      final response = await http.get(
        headers: {
          "Accept": "application/json",
          "Lang": sharedPreferences!.getString("local") == "en" ? "en" : "ar",
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'Bearer ${sharedPreferences!.getString("token")}'
        },
        Uri.parse(
            '${AppApi.storePower}?per_page=${perPage.value}&page=${currentPage.value}'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          // Parse pagination info
          if (jsonData['pagination'] != null) {
            currentPage.value = jsonData['pagination']['current_page'] ?? 1;
            lastPage.value = jsonData['pagination']['last_page'] ?? 1;
            perPage.value = jsonData['pagination']['per_page'] ?? 20;
            hasMoreData.value = currentPage.value < lastPage.value;
          }

          final List<PowerModel> newPowers = (jsonData['data'] as List)
              .map((item) => PowerModel.fromJson(item))
              .toList();

          if (isRefresh) {
            storePowers.assignAll(newPowers);
          } else {
            storePowers.assignAll(newPowers);
          }

          log('Loaded page ${currentPage.value} of ${lastPage.value}');
          log('Total items: ${storePowers.length}');
        } else {
          errorMessage(jsonData['message'] ?? 'Failed to load data');
        }
      } else {
        errorMessage('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error: $e');
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> loadMorePowers() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore(true);
      currentPage.value++;

      final response = await http.get(
        headers: {
          "Accept": "application/json",
          "Lang": sharedPreferences!.getString("local") == "en" ? "en" : "ar",
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'Bearer ${sharedPreferences!.getString("token")}'
        },
        Uri.parse(
            '${AppApi.storePower}?per_page=${perPage.value}&page=${currentPage.value}'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          // Update pagination info
          if (jsonData['pagination'] != null) {
            lastPage.value = jsonData['pagination']['last_page'] ?? 1;
            hasMoreData.value = currentPage.value < lastPage.value;
          }

          final List<PowerModel> newPowers = (jsonData['data'] as List)
              .map((item) => PowerModel.fromJson(item))
              .toList();

          storePowers.addAll(newPowers);

          log('Loaded page ${currentPage.value} of ${lastPage.value}');
          log('Total items: ${storePowers.length}');
        }
      }
    } catch (e) {
      log('Error loading more: $e');
      currentPage.value--; // Revert page increment on error
    } finally {
      isLoadingMore(false);
      update();
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchUserProfile(),
      fetchStorePowers(isRefresh: true),
    ]);
  }

  int index = 0;
  var closeEnergy = false.obs;

  changeIndex(i) {
    index = i;
    update();
  }

  StatuesRequest statuesRequest = StatuesRequest.none;

  final MarketRemoteData _marketRemoteData =
      MarketRemoteData(api: Get.find<Api>());

  closePower({required powerId, required status}) async {
    var response = await _marketRemoteData.closePower(
        powerId: powerId,
        status: status.toString());
    statuesRequest = handlingData(response);
    // ... باقي اللوجيك
    log(" token >>>> ${sharedPreferences!.getString("token")}");
    log(" token >>>> ${sharedPreferences!.getString("deviceId")}");
    log(" power >>>> ${response.toString()}");

    if (statuesRequest == StatuesRequest.success) {
      print(response);
      fetchUserProfile();
      if (response['code'] == "404") {
      } else {}
    } else {          showUserFriendlyError(statuesRequest);
}  update();
  }
}
