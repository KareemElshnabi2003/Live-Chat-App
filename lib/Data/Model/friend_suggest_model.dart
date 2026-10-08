import 'package:live_chat/Data/Model/power_model.dart';

class SuggestFreindModel {
  int? id;
  String? name;
  String? username;
  String? image;
  String? requestStatus;
  PowerModel? power;

  SuggestFreindModel(
      {this.id,
      this.name,
      this.username,
      this.image,
      this.requestStatus,
      this.power});

  SuggestFreindModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    
    image = json['image'];

    requestStatus = json['request_status'];
    power = json['power'] != null ? PowerModel.fromJson(json['power']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['image'] = image;
    data['request_status'] = requestStatus;
    if (power != null) {
      data['power'] = power!.toJson();
    }
    return data;
  }
}
