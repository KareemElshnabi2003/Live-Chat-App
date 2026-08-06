class NotifyModel {
  int? id;
  String? title;
  String? content;
  String? date;
  Map<String, dynamic>? additionalData;

  NotifyModel({
    this.id,
    this.title,
    this.content,
    this.date,
    this.additionalData,
  });

  NotifyModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      title = json['title'];
      content = json['content'];
      date = json['date'];

      // Handle additional_data safely
      if (json['additional_data'] != null) {
        if (json['additional_data'] is Map) {
          additionalData = Map<String, dynamic>.from(json['additional_data']);
        }
      }
    } catch (e) {
      // Set default values on error
      id = null;
      title = '';
      content = '';
      date = '';
      additionalData = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['date'] = date;
    data['additional_data'] = additionalData;
    return data;
  }
}
