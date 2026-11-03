class Category {
  String? sId;
  String? name;
  String? image;
  bool isSelected;
  bool isActive;
  int sortOrder;
  String? createdAt;
  String? updatedAt;

  Category({
    this.sId,
    this.name,
    this.image,
    this.isSelected = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json)
      : sId = json['_id'],
        name = json['name'],
        image = json['image'],
        isActive = json['isActive'] != false,
        sortOrder = (json['sortOrder'] as num?)?.toInt() ?? 0,
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        isSelected = false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
