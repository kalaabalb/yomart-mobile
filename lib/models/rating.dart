class Rating {
  String? sId;
  String? productId;
  String? userId;
  int? rating;
  String? review;
  String? userName;
  bool? verifiedPurchase;
  String? createdAt;
  String? updatedAt;

  Rating({
    this.sId,
    this.productId,
    this.userId,
    this.rating,
    this.review,
    this.userName,
    this.verifiedPurchase,
    this.createdAt,
    this.updatedAt,
  });

  Rating.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'];
    rating = json['rating'];
    review = json['review'];
    userName = json['userName'];
    verifiedPurchase = json['verifiedPurchase'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['productId'] = productId;
    data['userId'] = userId;
    data['rating'] = rating;
    data['review'] = review;
    data['userName'] = userName;
    data['verifiedPurchase'] = verifiedPurchase;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class RatingStats {
  double? averageRating;
  int? ratingCount;
  Map<String, int>? distribution;

  RatingStats({
    this.averageRating,
    this.ratingCount,
    this.distribution,
  });

  RatingStats.fromJson(Map<String, dynamic> json) {
    averageRating = json['averageRating']?.toDouble();
    ratingCount = json['ratingCount'];

    if (json['distribution'] != null) {
      distribution = Map<String, int>.from(json['distribution']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['averageRating'] = averageRating;
    data['ratingCount'] = ratingCount;
    data['distribution'] = distribution;
    return data;
  }

  double get percentage5Star {
    if (ratingCount == 0) return 0.0;
    return ((distribution?['5'] ?? 0) / ratingCount!) * 100;
  }

  double get percentage4Star {
    if (ratingCount == 0) return 0.0;
    return ((distribution?['4'] ?? 0) / ratingCount!) * 100;
  }

  double get percentage3Star {
    if (ratingCount == 0) return 0.0;
    return ((distribution?['3'] ?? 0) / ratingCount!) * 100;
  }

  double get percentage2Star {
    if (ratingCount == 0) return 0.0;
    return ((distribution?['2'] ?? 0) / ratingCount!) * 100;
  }

  double get percentage1Star {
    if (ratingCount == 0) return 0.0;
    return ((distribution?['1'] ?? 0) / ratingCount!) * 100;
  }
}

class RatingResponse {
  List<Rating>? ratings;
  double? averageRating;
  int? ratingCount;
  int? totalPages;
  int? currentPage;

  RatingResponse({
    this.ratings,
    this.averageRating,
    this.ratingCount,
    this.totalPages,
    this.currentPage,
  });

  RatingResponse.fromJson(Map<String, dynamic> json) {
    if (json['ratings'] != null) {
      ratings = <Rating>[];
      json['ratings'].forEach((v) {
        ratings!.add(Rating.fromJson(v));
      });
    }
    averageRating = json['averageRating']?.toDouble();
    ratingCount = json['ratingCount'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ratings != null) {
      data['ratings'] = ratings!.map((v) => v.toJson()).toList();
    }
    data['averageRating'] = averageRating;
    data['ratingCount'] = ratingCount;
    data['totalPages'] = totalPages;
    data['currentPage'] = currentPage;
    return data;
  }
}
