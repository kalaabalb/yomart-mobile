class Poster {
  String? sId;
  String? posterName;
  String? imageUrl;
  String? subtitle;
  bool isActive = true;
  int sortOrder = 0;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Poster(
      {this.sId,
      this.posterName,
      this.imageUrl,
      this.subtitle,
      this.isActive = true,
      this.sortOrder = 0,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Poster.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    posterName = json['posterName'];
    imageUrl = json['imageUrl'];
    subtitle = json['subtitle']?.toString();
    isActive = json['isActive'] != false;
    sortOrder = (json['sortOrder'] as num?)?.toInt() ?? 0;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['posterName'] = posterName;
    data['imageUrl'] = imageUrl;
    data['subtitle'] = subtitle;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
