class PinChatRequest {
  final int conversationId;
  final bool hasAd;
  final String? adTitle;
  final String? adLink;
  final String pinDate;
  final List<PinHour> pinHours;

  PinChatRequest({
    required this.conversationId,
    required this.hasAd,
    this.adTitle,
    this.adLink,
    required this.pinDate,
    required this.pinHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'has_ad': hasAd,
      if (adTitle != null) 'ad_title': adTitle,
      if (adLink != null) 'ad_link': adLink,
      'pin_date': pinDate,
      'pin_hours': pinHours.map((hour) => hour.toJson()).toList(),
    };
  }
}

class PinHour {
  final int hour;
  final String period;

  PinHour({required this.hour, required this.period});

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'period': period,
    };
  }
}

class PinChatResponse {
  final String status;
  final int code;
  final String message;
  final Map<String, List<String>>? validationErrors;
  final Map<String, dynamic>? data;

  PinChatResponse({
    required this.status,
    required this.code,
    required this.message,
    this.validationErrors,
    this.data,
  });

  factory PinChatResponse.fromJson(Map<String, dynamic> json) {
    return PinChatResponse(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      validationErrors: json['validation_errors'] != null
          ? Map<String, List<String>>.from(
              json['validation_errors'].map(
                (key, value) => MapEntry(
                  key,
                  List<String>.from(value),
                ),
              ),
            )
          : null,
      data: json['data'],
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;
}
