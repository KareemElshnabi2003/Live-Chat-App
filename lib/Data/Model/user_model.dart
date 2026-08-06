import 'package:live_chat/Data/Model/power_model.dart';

class UserModel {
  int? id;
  String? name;
  String? username;
  String? email;
  String? phone;
  String? image;
  String? gender;
  String? age;
  String? countryId;
  String? countryName;
  String? numberOfStars;
  PowerModel? power;
  String? bio;

  UserModel(
      {this.id,
      this.bio,
      this.power,
      this.name,
      this.username,
      this.email,
      this.phone,
      this.image,
      this.gender,
      this.age,
      this.countryId,
      this.countryName,
      this.numberOfStars});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bio = json['bio'];
    power = json['user_power'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    gender = json['gender'];
    age = json['age'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    numberOfStars = json['number_of_stars'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bio'] = bio;
    data['user_power'] = power;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['phone'] = phone;
    data['image'] = image;
    data['gender'] = gender;
    data['age'] = age;
    data['country_id'] = countryId;
    data['country_name'] = countryName;
    data['number_of_stars'] = numberOfStars;
    return data;
  }
}
