class RadioModel {
  final int id;
  final String radioUrl;
  final String name;

  RadioModel({
    required this.id,
    required this.radioUrl, required this.name,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      name: json['name'],
      id: json['id'] ?? 0,
      radioUrl: json['radio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'radio_url': radioUrl,
      "name":name
    };
  }

  @override
  String toString() {
    return 'RadioModel{id: $id, radioUrl: $radioUrl}';
  }
}
