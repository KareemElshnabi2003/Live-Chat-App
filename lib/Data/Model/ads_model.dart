class AdsModel {
  int? id;
  String? image;
  String? link;

  AdsModel({this.id, this.image, this.link});

  AdsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['link'] = link;
    return data;
  }
}
