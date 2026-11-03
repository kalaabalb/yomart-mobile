class Brand {
  String? sId;
  String? name;
  String? logoUrl;
  bool isActive = true;
  int sortOrder = 0;
  SubcategoryId? subcategoryId;
  String? createdAt;
  String? updatedAt;

  Brand(
      {this.sId,
      this.name,
      this.logoUrl,
      this.isActive = true,
      this.sortOrder = 0,
      this.subcategoryId,
      this.createdAt,
      this.updatedAt});

  Brand.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    logoUrl = json['logoUrl']?.toString();
    isActive = json['isActive'] != false;
    sortOrder = (json['sortOrder'] as num?)?.toInt() ?? 0;
    subcategoryId = json['subcategoryId'] != null
        ? SubcategoryId.fromJson(json['subcategoryId'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['logoUrl'] = logoUrl;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    if (subcategoryId != null) {
      data['subcategoryId'] = subcategoryId!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class SubcategoryId {
  String? sId;
  String? name;
  String? categoryId;
  String? createdAt;
  String? updatedAt;

  SubcategoryId(
      {this.sId, this.name, this.categoryId, this.createdAt, this.updatedAt});

  SubcategoryId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryId = json['categoryId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['categoryId'] = categoryId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
