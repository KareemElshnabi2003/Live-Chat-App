class PowerModel {
  int? id;
  String? price;
  int? status;
  int? isPurches;
  int? powerId;
  String? active;
  Effects? effects;
  String? expireAt;

  PowerModel(
      {this.id,
      this.isPurches,
      this.price,
      this.status,
      this.effects,
      this.expireAt});

  PowerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isPurches = json['is_purchased'];
    active = json['active'] ?? "";
    powerId = json['power_id'];
    price = json['price'];
    expireAt = json['expire_at'] ?? "";
    status = json['status'];
    effects =
        json['effects'] != null ? Effects.fromJson(json['effects']) : null;
  }

  Map toJson() {
    final Map data = {};
    data['id'] = id;
    data['is_purchased'] = isPurches;
    data['active'] = active;
    data['power_id'] = powerId;
    data['price'] = price;
    data['status'] = status;
    if (effects != null) {
      data['effects'] = effects!.toJson();
    }
    return data;
  }
}

class Effects {
  Power? power;
  Bio? bio;

  Effects({this.power, this.bio});

  Effects.fromJson(Map<String, dynamic> json) {
    power = json['power'] != null ? Power.fromJson(json['power']) : null;
    bio = json['bio'] != null ? Bio.fromJson(json['bio']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (power != null) {
      data['power'] = power!.toJson();
    }
    if (bio != null) {
      data['bio'] = bio!.toJson();
    }
    return data;
  }
}

class Power {
  String? leftGif;
  String? rightGif;
  String? shadow;
  String? textStyle;
  String? opacity;
  String? fontSize;
  String? fontName;
  String? color;
  String? type;
  String? speed;
  String? duration;
  String? direction;
  String? repeat;
  List<GradientColors>? gradientColors;
  String? gradientDirection;
  bool? gradientMovementStatus;

  Power(
      {this.leftGif,
      this.rightGif,
      this.shadow,
      this.textStyle,
      this.opacity,
      this.fontSize,
      this.fontName,
      this.color,
      this.type,
      this.speed,
      this.duration,
      this.direction,
      this.repeat,
      this.gradientColors,
      this.gradientDirection,
      this.gradientMovementStatus});

  Power.fromJson(Map<String, dynamic> json) {
    leftGif = json['left_gif'];
    rightGif = json['right_gif'];
    shadow = json['shadow'];
    textStyle = json['text_style'];
    opacity = json['opacity'];
    fontSize = json['font_size'];
    fontName = json['font_name'];
    color = json['color'];
    type = json['type'];
    speed = json['speed'];
    duration = json['duration'];
    direction = json['direction'];
    repeat = json['repeat'];
    if (json['gradient_colors'] != null) {
      gradientColors = <GradientColors>[];
      json['gradient_colors'].forEach((v) {
        gradientColors!.add(GradientColors.fromJson(v));
      });
    }
    gradientDirection = json['gradient_direction'];
    gradientMovementStatus = json['gradient_movement_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['left_gif'] = leftGif;
    data['right_gif'] = rightGif;
    data['shadow'] = shadow;
    data['text_style'] = textStyle;
    data['opacity'] = opacity;
    data['font_size'] = fontSize;
    data['font_name'] = fontName;
    data['color'] = color;
    data['type'] = type;
    data['speed'] = speed;
    data['duration'] = duration;
    data['direction'] = direction;
    data['repeat'] = repeat;
    if (gradientColors != null) {
      data['gradient_colors'] = gradientColors!.map((v) => v.toJson()).toList();
    }
    data['gradient_direction'] = gradientDirection;
    data['gradient_movement_status'] = gradientMovementStatus;
    return data;
  }
}

class GradientColors {
  String? color;

  GradientColors({this.color});

  GradientColors.fromJson(Map<String, dynamic> json) {
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    return data;
  }
}

class Bio {
  String? text;
  String? shadow;
  String? textStyle;
  String? opacity;
  String? fontSize;
  String? fontName;
  String? color;
  String? type;
  String? speed;
  String? duration;
  String? direction;
  String? repeat;
  List<GradientColors>? gradientColors;
  String? gradientDirection;
  bool? gradientMovementStatus;

  Bio(
      {this.text,
      this.shadow,
      this.textStyle,
      this.opacity,
      this.fontSize,
      this.fontName,
      this.color,
      this.type,
      this.speed,
      this.duration,
      this.direction,
      this.repeat,
      this.gradientColors,
      this.gradientDirection,
      this.gradientMovementStatus});

  Bio.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    shadow = json['shadow'];
    textStyle = json['text_style'];
    opacity = json['opacity'];
    fontSize = json['font_size'];
    fontName = json['font_name'];
    color = json['color'];
    type = json['type'];
    speed = json['speed'];
    duration = json['duration'];
    direction = json['direction'];
    repeat = json['repeat'].toString();
    if (json['gradient_colors'] != null) {
      gradientColors = <GradientColors>[];
      json['gradient_colors'].forEach((v) {
        gradientColors!.add(GradientColors.fromJson(v));
      });
    }
    gradientDirection = json['gradient_direction'];
    gradientMovementStatus = json['gradient_movement_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['shadow'] = shadow;
    data['text_style'] = textStyle;
    data['opacity'] = opacity;
    data['font_size'] = fontSize;
    data['font_name'] = fontName;
    data['color'] = color;
    data['type'] = type;
    data['speed'] = speed;
    data['duration'] = duration;
    data['direction'] = direction;
    data['repeat'] = repeat;
    if (gradientColors != null) {
      data['gradient_colors'] = gradientColors!.map((v) => v.toJson()).toList();
    }
    data['gradient_direction'] = gradientDirection;
    data['gradient_movement_status'] = gradientMovementStatus;
    return data;
  }
}
