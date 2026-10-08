import 'dart:async';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/Data/Model/radio_model.dart';
import 'package:live_chat/main.dart';

class RadioRemoteData {
  final Api api;

  RadioRemoteData({required this.api});
  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  Future<List<RadioModel>> getRadios() async {
    try {
      var response = await api.getData("${AppApi.getRadiosUrl}?device_id=$deviceId");

      return response.fold(
              (l) => throw Exception('Error fetching radios: $l'),
              (r) {
            if (r['status'] == 'success') {
              List<dynamic> data = r['data'];
              return data.map((json) => RadioModel.fromJson(json)).toList();
            } else {
              throw Exception('Failed to load radios: ${r['message']}');
            }
          }
      );
    } catch (e) {
      throw Exception('Error fetching radios: $e');
    }
  }
}