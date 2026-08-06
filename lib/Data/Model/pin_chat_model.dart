import 'package:live_chat/Data/Model/user_chat_model.dart';

class PINChatModel {
  int? id;
  String? name;
  String? image;
  String? slug;
  String? chatLink;
  ThemeId? themeId;
  String? userTheme;
  User? user;
  String? createdAt;
  String? updatedAt;
  List<Messages>? messages;
  List<Members>? members;
  String? adTitle;
  String? adLink;
  String? adImage; // Added ad_image field

  PINChatModel({
    this.id,
    this.name,
    this.image,
    this.slug,
    this.chatLink,
    this.themeId,
    this.userTheme,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.messages,
    this.members,
    this.adTitle,
    this.adLink,
    this.adImage, // Added ad_image parameter
  });

  PINChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    slug = json['slug'];
    chatLink = json['chat_link'];
    themeId =
        json['theme_id'] != null ? ThemeId.fromJson(json['theme_id']) : null;
    userTheme = json['user_theme'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(Members.fromJson(v));
      });
    }
    adTitle = json['ad_title'];
    adLink = json['ad_link'];
    adImage = json['ad_image']; // Parse ad_image from JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['slug'] = slug;
    data['chat_link'] = chatLink;
    if (themeId != null) {
      data['theme_id'] = themeId!.toJson();
    }
    data['user_theme'] = userTheme;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    data['ad_title'] = adTitle;
    data['ad_link'] = adLink;
    data['ad_image'] = adImage; // Include ad_image in toJson
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

class Messages {
  int? id;
  int? conversationId;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  List<MessageReactions>? messageReactions;

  Messages({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.messageReactions,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    message = json['message'];
    if (json['message_reactions'] != null) {
      messageReactions = <MessageReactions>[];
      json['message_reactions'].forEach((v) {
        messageReactions!.add(MessageReactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['sender_image'] = senderImage;
    data['message'] = message;
    if (messageReactions != null) {
      data['message_reactions'] =
          messageReactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessageReactions {
  int? id;
  String? react;

  MessageReactions({this.id, this.react});

  MessageReactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    react = json['react'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['react'] = react;
    return data;
  }
}

class Members {
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

  Members({
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

  Members.fromJson(Map<String, dynamic> json) {
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
