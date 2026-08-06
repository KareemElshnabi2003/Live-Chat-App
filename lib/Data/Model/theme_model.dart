class ThemeModel {
  int? id;
  String? theme;

  ThemeModel({this.id, this.theme});

  ThemeModel.fromJson(Map<String, dynamic> json) {
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
