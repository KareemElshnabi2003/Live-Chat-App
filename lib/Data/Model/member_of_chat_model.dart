import 'package:live_chat/Data/Model/power_model.dart';

class MemberOfChatModel {
  int? id;
  String? username;
  String? image;
  bool? isGuest;
  String? memberStatus;
  String? requestStatus;
  int? isAdmin;
  PowerModel? power;

  MemberOfChatModel(
      {this.id,
      this.username,
      this.image,
      this.isGuest,
      this.memberStatus,
      this.requestStatus,
      this.isAdmin,
      this.power});

  MemberOfChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    image = json['image'];
    isGuest = json['is_guest'];
    memberStatus = json['member_status'];
    requestStatus = json['request_status'];
    isAdmin = json['is_admin'];
    power = json['power'] != null ? PowerModel.fromJson(json['power']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['image'] = image;
    data['is_guest'] = isGuest;
    data['member_status'] = memberStatus;
    data['request_status'] = requestStatus;
    data['is_admin'] = isAdmin;
    if (power != null) {
      data['power'] = power!.toJson();
    }
    return data;
  }
}
