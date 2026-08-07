
import 'package:live_chat/Data/Model/message_model.dart';

class UserChatModel {
  int? id;
  String? name;
  String? image;
  String? slug;
  String? status;
  String? accept;
  String? chatLink;
  User? user;
  List<ChatAdmins>? chatAdmins;
  ThemeId? themeId;
  String? userTheme;
  int? membersCount;
  int? messagesCount;
  String? createdAt;
  String? updatedAt;
  String? adLink;
  String? adTitle;
  String? adImage; // Added ad_image field
  List<MessageModel>? messages;
  LastMessage? lastMessage;
  int? unreadCount;
  String? isBlocked;

  UserChatModel({
    this.id,
    this.isBlocked,
    this.name,
    this.image,
    this.lastMessage,
    this.unreadCount,
    this.slug,
    this.status,
    this.accept,
    this.chatLink,
    this.user,
    this.chatAdmins,
    this.themeId,
    this.userTheme,
    this.membersCount,
    this.messagesCount,
    this.createdAt,
    this.adLink,
    this.adTitle,
    this.adImage, // Added ad_image parameter
    this.updatedAt,
  });

  UserChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isBlocked = json['is_blocked'];
    adLink = json['ad_link'];
    adTitle = json['ad_title'];
    adImage = json['ad_image']; // Parse ad_image from JSON
    name = json['name'];
    image = json['image'];
    slug = json['slug'];
    status = json['status'].toString();
    accept = json['accept'].toString();
    lastMessage = json['last_message'] != null
        ? LastMessage.fromJson(json['last_message'])
        : null;
    unreadCount = json['unread_count'];
    chatLink = json['chat_link'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['chat_admins'] != null) {
      chatAdmins = <ChatAdmins>[];
      json['chat_admins'].forEach((v) {
        chatAdmins!.add(ChatAdmins.fromJson(v));
      });
    }
    themeId = json['theme'] != null ? ThemeId.fromJson(json['theme']) : null;
    userTheme = json['user_theme'];
    membersCount = json['members_count'];

    messagesCount = json['messages_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['slug'] = slug;
    data['status'] = status;
    data['accept'] = accept;
    data['is_blocked'] = isBlocked;
    data['chat_link'] = chatLink;
    if (lastMessage != null) {
      data['last_message'] = lastMessage!.toJson();
    }
    data['unread_count'] = unreadCount;
    data['ad_link'] = adLink;
    data['ad_title'] = adTitle;
    data['ad_image'] = adImage; // Include ad_image in toJson
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (chatAdmins != null) {
      data['chat_admins'] = chatAdmins!.map((v) => v.toJson()).toList();
    }
    if (themeId != null) {
      data['theme'] = themeId!.toJson();
    }
    data['user_theme'] = userTheme;
    data['members_count'] = membersCount;
    data['messages_count'] = messagesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? phone;
  String? image;
  String? gender;
  String? age;
  int? countryId;
  String? countryName;
  int? numberOfStars;

  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.phone,
    this.image,
    this.gender,
    this.age,
    this.countryId,
    this.countryName,
    this.numberOfStars,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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

class ChatAdmins {
  String? chatAdminId;

  ChatAdmins({this.chatAdminId});

  ChatAdmins.fromJson(Map<String, dynamic> json) {
    chatAdminId = json['chat_admin_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_admin_id'] = chatAdminId;
    return data;
  }
}

class ThemeId {
  int? id;
  String? theme;

  ThemeId({this.id, this.theme});

  ThemeId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    theme = json['theme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['theme'] = theme;
    return data;
  }
}

class LastMessage {
  int? id;
  int? conversationId;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  String? messageType;
  String? createdAt;

  LastMessage({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.messageType,
    this.createdAt,
  });

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    message = json['message'];
    messageType = json['message_type'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['sender_image'] = senderImage;
    data['message'] = message;
    data['message_type'] = messageType;
    data['created_at'] = createdAt;
    return data;
  }
}
