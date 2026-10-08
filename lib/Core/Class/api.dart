import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handle_exception.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/main.dart';

class Api extends GetxService {
  final http.Client _client = http.Client();
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const Duration _uploadTimeout = Duration(seconds: 30);

  // لمنع ظهور أكثر من نافذة حوار في نفس الوقت لو في كذا ريكويست فشلوا مع بعض
  static bool _isDialogShowing = false;

  // 🌟 [متغير جديد] للاحتفاظ برسالة الباك إند مؤقتاً
  static String? serverMessage;

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    String? token = sharedPreferences!.getString("token");

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json; charset=UTF-8",
      "Lang": sharedPreferences!.getString("local") == "en" ? "en" : "ar",
    };
    //
    if (token != null && token.isNotEmpty && token != "null") {
      headers["Authorization"] = "Bearer $token";
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    print("📤 Headers being sent: $headers");
    return headers;
  }

  // 🌟 استخراج رسالة الخطأ من الباك إند
  void _extractServerMessage(String body) {
    try {
      final decodedData = jsonDecode(body);
      serverMessage =
          decodedData['message'] ?? decodedData['msg'] ?? decodedData['error'];
    } catch (e) {
      serverMessage = null;
    }
  }

  Either<StatuesRequest, dynamic> _handleResponse(http.Response response) {
    // تصفير الرسالة مع كل ريكويست جديد
    serverMessage = null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return right(data);
    }
    
    if (response.statusCode == 204) {
      log('204 No Content (Success): ${response.body}');
      return right({"status": "success"}); // إرجاع نجاح بدون محاولة فك تشفير JSON لأن البودي فاضي
    }

    if ([400, 402, 403, 404, 409, 422].contains(response.statusCode)) {
      _extractServerMessage(response.body);
    }

   
    switch (response.statusCode) {
      case 400:
        log('400 Bad Request: ${response.body}');
        return left(StatuesRequest.badRequestException);
      case 401:
        log('401 Unauthorized: ${response.body}');
        _handleUnauthorized();
        return left(StatuesRequest.unauthorizedException);
      case 403:
        log('403 Forbidden: ${response.body}');
        return left(StatuesRequest.forbiddenException);
      case 404:
        log('404 Not Found: ${response.body}');
        return left(StatuesRequest.serverException);
      case 409:
        log('409 Conflict: ${response.body}');
        return left(StatuesRequest.conflictException);
      case 422:
        log('422 Validation Error: ${response.body}');
        return left(StatuesRequest.unprocessableException);
      case 500:
        log('500 Server Error: ${response.body}');
        return left(StatuesRequest.serverError);
      default:
        log('Unexpected ${response.statusCode}: ${response.body}');
        return left(StatuesRequest.defaultException);
    }
  }

  Either<StatuesRequest, dynamic> _handleError(dynamic e) {
    serverMessage = null;
    if (e is SocketException) return left(StatuesRequest.socketException);
    if (e is http.ClientException) return left(StatuesRequest.clientException);
    if (e is TimeoutException) return left(StatuesRequest.timeoutException);
    return left(handleException(e));
  }

  void _handleUnauthorized() {
    if(sharedPreferences!.getString("page")!=null){  if (!_isDialogShowing) {
      _isDialogShowing = true;
      Get.defaultDialog(
        title: "تسجيل الدخول مطلوب",
        middleText:
        "عفواً، يجب عليك تسجيل الدخول أو إنشاء حساب لتتمكن من عرض هذا المحتوى. هل تود تسجيل الدخول الآن؟",
        textConfirm: "موافق",
        textCancel: "إلغاء",
        confirmTextColor: Colors.white,
        buttonColor: Colors.blue,
        barrierDismissible: false,
        onConfirm: () {
          _isDialogShowing = false;
          sharedPreferences!.clear();
          Get.back();
          Get.offAll(() => const PageStart());
        },
        onCancel: () {
          _isDialogShowing = false;
          Get.back();
        },
      );
    }}

  }

  Future<Either<StatuesRequest, dynamic>> getData(String linkUrl,
      {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(Uri.parse(linkUrl), headers: _getHeaders(headers))
          .timeout(_requestTimeout);
      print("🔗 Full URL: $linkUrl");
      print("📥 Status Code: ${response.statusCode}");
      print("📥 Body: ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> postData(String linkUrl, Map data,
      [Map<String, String>? headers]) async {
    final dataPost = jsonEncode(data);
    try {
      final response = await _client
          .post(Uri.parse(linkUrl),
              headers: _getHeaders(headers), body: dataPost)
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> updatePutData(
      String linkUrl, Map data,
      [Map<String, String>? headers]) async {
    final dataPost = jsonEncode(data);
    try {
      final response = await _client
          .put(Uri.parse(linkUrl),
              headers: _getHeaders(headers), body: dataPost)
          .timeout(_requestTimeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> updatePatchData(
      String linkUrl, Map data,
      [Map<String, String>? headers]) async {
    final dataPost = jsonEncode(data);
    try {
      final response = await _client
          .patch(Uri.parse(linkUrl),
              headers: _getHeaders(headers), body: dataPost)
          .timeout(_requestTimeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> deleteData(String linkUrl,
      [Map<String, String>? headers]) async {
    try {
      final response = await _client
          .delete(Uri.parse(linkUrl), headers: _getHeaders(headers))
          .timeout(_requestTimeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> postRequestwithfile(
      String url, Map data, File? image_1, File? image_2) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll(_getHeaders(null));

      final fileFutures = <Future<http.MultipartFile>>[];
      if (image_1 != null) {
        fileFutures.add(http.MultipartFile.fromPath("image", image_1.path));
      }
      if (image_2 != null) {
        fileFutures
            .add(http.MultipartFile.fromPath("user_theme", image_2.path));
      }

      if (fileFutures.isNotEmpty) {
        request.files.addAll(await Future.wait(fileFutures));
      }

      data.forEach((key, value) {
        if (value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      var myrequest = await _client.send(request).timeout(_uploadTimeout);
      var response = await http.Response.fromStream(myrequest);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> updateRequestwithfile(
      String url, Map data, File? image_1, File? image_2) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll(_getHeaders(null));

      final fileFutures = <Future<http.MultipartFile>>[];
      if (image_1 != null) {
        fileFutures.add(http.MultipartFile.fromPath("image", image_1.path));
      }
      if (image_2 != null) {
        fileFutures
            .add(http.MultipartFile.fromPath("user_theme", image_2.path));
      }

      if (fileFutures.isNotEmpty) {
        request.files.addAll(await Future.wait(fileFutures));
      }
      data.forEach((key, value) {
        if (value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      var myrequest = await _client.send(request).timeout(_uploadTimeout);
      var response = await http.Response.fromStream(myrequest);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<StatuesRequest, dynamic>> postDataWithRecordAndImage(
      String url, Map data, File? image_1, File? audio) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll(_getHeaders(null));

      final fileFutures = <Future<http.MultipartFile>>[];
      if (image_1 != null) {
        fileFutures.add(http.MultipartFile.fromPath("message", image_1.path));
      }
      if (audio != null) {
        fileFutures.add(http.MultipartFile.fromPath("message", audio.path));
      }

      if (fileFutures.isNotEmpty) {
        request.files.addAll(await Future.wait(fileFutures));
      }

      data.forEach((key, value) {
        if (value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      var myrequest = await _client.send(request).timeout(_uploadTimeout);
      var response = await http.Response.fromStream(myrequest);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
}
