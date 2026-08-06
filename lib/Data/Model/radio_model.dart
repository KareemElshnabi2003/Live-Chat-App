class RadioModel {
  final int id;
  final String radioUrl;

  RadioModel({
    required this.id,
    required this.radioUrl,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['id'] ?? 0,
      radioUrl: json['radio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'radio_url': radioUrl,
    };
  }

  @override
  String toString() {
    return 'RadioModel{id: $id, radioUrl: $radioUrl}';
  }
}
