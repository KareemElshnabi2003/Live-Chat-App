import 'dart:convert';
import 'package:live_chat/Data/Model/user_chat_model.dart';

class PinChatModel {
  int? id;
  int? conversationId;
  int? numberOfStars;
  int? hasAd;
  String? adTitle;
  String? adLink;
  String? adImage;
  int? status;
  String? pinDate;
  // 🌟 التعديل 1: غيرنا النوع لـ List عشان يقرا المصفوفة صح
  List<PinHour>? pinHours;
  UserChatModel? conversation;

  PinChatModel(
      {this.id,
        this.conversationId,
        this.numberOfStars,
        this.hasAd,
        this.adTitle,
        this.adLink,
        this.adImage,
        this.status,
        this.pinDate,
        this.pinHours,
        this.conversation});

  PinChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    numberOfStars = json['number_of_stars'];
    hasAd = json['has_ad'];
    adTitle = json['ad_title'];
    adLink = json['ad_link'];
    adImage = json['ad_image'];
    status = json['status'];
    pinDate = json['pin_date'];

    // 🌟 التعديل 2: معالجة ذكية للـ pin_hours (سواء رجعت List أو String)
    if (json['pin_hours'] != null) {
      pinHours = [];
      if (json['pin_hours'] is List) {
        // لو راجعة مصفوفة طبيعية
        json['pin_hours'].forEach((v) {
          pinHours!.add(PinHour.fromJson(v));
        });
      } else if (json['pin_hours'] is String) {
        // لو الباك إند رجعها كنص بالغلط
        try {
          var decoded = jsonDecode(json['pin_hours']);
          if (decoded is List) {
            for (var v in decoded) {
              pinHours!.add(PinHour.fromJson(v));
            }
          }
        } catch (e) {
          print("Error parsing pin_hours string: $e");
        }
      }
    }

    // 🌟 فحص الـ conversation زي ما عملنا قبل كده
    conversation = json['conversation'] != null
        ? UserChatModel.fromJson(json['conversation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['number_of_stars'] = numberOfStars;
    data['has_ad'] = hasAd;
    data['ad_title'] = adTitle;
    data['ad_link'] = adLink;
    data['ad_image'] = adImage;
    data['status'] = status;
    data['pin_date'] = pinDate;
    if (pinHours != null) {
      data['pin_hours'] = pinHours!.map((v) => v.toJson()).toList();
    }
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    return data;
  }
}

// 🌟 كلاس جديد مخصص لساعات التثبيت عشان الكود يبقى Clean ويسهل استخدامه
class PinHour {
  int? hour;
  String? period;

  PinHour({this.hour, this.period});

  PinHour.fromJson(Map<String, dynamic> json) {
    hour = json['hour'];
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hour'] = hour;
    data['period'] = period;
    return data;
  }
}