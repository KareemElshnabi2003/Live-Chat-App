import 'dart:io';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class StarsPurchaseService {
  final String baseUrl = AppApi.baseUrl;
  final Api api = Get.find<Api>(); // ربطناه بالـ Singleton
  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  Future<dynamic> getPaymentOptions() async {
    try {
      var response =
          await api.getData('$baseUrl/manual_payment_orders/payment_options?device_id=$deviceId');
      return response.fold(
          (l) =>
              {'status': 'error', 'message': 'Failed to get payment options'},
          (r) => r);
    } catch (e) {
      throw Exception('Failed to get payment options: $e');
    }
  }

  Future<dynamic> getPaymentMethods() async {
    try {
      var response = await api.getData('$baseUrl/manual_payment_data?device_id=$deviceId');
      return response.fold(
          (l) =>
              {'status': 'error', 'message': 'Failed to get payment methods'},
          (r) => r);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  Future<dynamic> submitManualPayment({
    required File image,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) async {
    try {
      Map<String, dynamic> data = {
        'price': price,
        'paymentAddress': paymentAddress,
        'paymentType': paymentType,
        'stars': stars,
      };

      var response = await api.postRequestwithfile(
          '$baseUrl/manual_payment_orders?device_id=$deviceId', data, image, null);

      return response.fold(
          (l) => {'status': 'error', 'message': 'Failed to submit payment'},
          (r) => r);
    } catch (e) {
      throw Exception('Failed to submit manual payment: $e');
    }
  }



  Future<Map<String, dynamic>> createPaymentUrl({
    required String numberOfStars,
  }) async {
    try {
      var response = await api.postData('$baseUrl/your_payment_endpoint?device_id=$deviceId', {
        'stars': numberOfStars,
      });

      return response.fold(
          (l) => {'status': 'error', 'message': 'Failed to create payment URL'},
          (r) => r as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create payment URL: $e');
    }
  }
}
