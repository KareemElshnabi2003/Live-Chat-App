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
  String? pinHours;
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
    pinHours = json['pin_hours'];
    conversation = UserChatModel.fromJson(json['conversation']);
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
    data['pin_hours'] = pinHours;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    return data;
  }
}
