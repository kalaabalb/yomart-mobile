class Order {
  ShippingAddress? shippingAddress;
  OrderTotal? orderTotal;
  String? sId;
  UserID? userID;
  String? orderStatus;
  List<Items>? items;
  double? totalPrice;
  String? paymentMethod;
  PaymentMethodSnapshot? paymentMethodSnapshot;
  String? paymentStatus;
  PaymentProof? paymentProof;
  CollectionPoint? collectionPoint;
  String? trackingUrl;
  String? orderDate;
  int? iV;

  Order({
    this.shippingAddress,
    this.orderTotal,
    this.sId,
    this.userID,
    this.orderStatus,
    this.items,
    this.totalPrice,
    this.paymentMethod,
    this.paymentMethodSnapshot,
    this.paymentStatus,
    this.paymentProof,
    this.collectionPoint,
    this.trackingUrl,
    this.orderDate,
    this.iV,
  });

  Order.fromJson(Map<String, dynamic> json) {
    shippingAddress = json['shippingAddress'] != null
        ? ShippingAddress.fromJson(json['shippingAddress'])
        : null;
    orderTotal = json['orderTotal'] != null
        ? OrderTotal.fromJson(json['orderTotal'])
        : null;
    sId = json['_id'];
    userID = json['userID'] != null ? UserID.fromJson(json['userID']) : null;
    orderStatus = json['orderStatus'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    totalPrice = json['totalPrice']?.toDouble();
    paymentMethod = json['paymentMethod'];
    paymentMethodSnapshot = json['paymentMethodSnapshot'] is Map<String, dynamic>
        ? PaymentMethodSnapshot.fromJson(json['paymentMethodSnapshot'])
        : null;
    paymentStatus = json['paymentStatus'];
    paymentProof = json['paymentProof'] != null
        ? PaymentProof.fromJson(json['paymentProof'])
        : null;
    collectionPoint = json['collectionPoint'] is Map<String, dynamic>
        ? CollectionPoint.fromJson(json['collectionPoint'])
        : null;
    trackingUrl = json['trackingUrl'];
    orderDate = json['orderDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shippingAddress != null) {
      data['shippingAddress'] = shippingAddress!.toJson();
    }
    if (orderTotal != null) {
      data['orderTotal'] = orderTotal!.toJson();
    }
    data['_id'] = sId;
    if (userID != null) {
      data['userID'] = userID!.toJson();
    }
    data['orderStatus'] = orderStatus;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['totalPrice'] = totalPrice;
    data['paymentMethod'] = paymentMethod;
    if (paymentMethodSnapshot != null) {
      data['paymentMethodSnapshot'] = paymentMethodSnapshot!.toJson();
    }
    data['paymentStatus'] = paymentStatus;
    if (paymentProof != null) {
      data['paymentProof'] = paymentProof!.toJson();
    }
    if (collectionPoint != null) {
      data['collectionPoint'] = collectionPoint!.toJson();
    }
    data['trackingUrl'] = trackingUrl;
    data['orderDate'] = orderDate;
    data['__v'] = iV;
    return data;
  }

  // Helper methods
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentVerified => paymentStatus == 'verified';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get isCashOnDelivery => paymentMethodSnapshot?.category == 'cash_collection' || paymentMethod == 'cod';
  bool get isBankTransfer => paymentMethodSnapshot?.category == 'bank_transfer' || paymentMethod == 'cbe';
  bool get isMobilePayment => paymentMethodSnapshot?.category == 'mobile_wallet' || paymentMethod == 'telebirr';

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'verified':
        return 'Payment Verified';
      case 'failed':
        return 'Payment Failed';
      case 'pending':
      default:
        return 'Payment Pending';
    }
  }

  String get orderStatusDisplay {
    switch (orderStatus) {
      case 'payment_pending':
        return 'Awaiting Payment';
      case 'payment_verified':
        return 'Payment Verified';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'ready_for_collection':
        return 'Ready for Collection';
      case 'collected':
        return 'Collected';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}

class PaymentMethodSnapshot {
  final String code;
  final String name;
  final String description;
  final String category;
  final String logoUrl;
  final String providerName;
  final String accountHolder;
  final String accountIdentifier;
  final String additionalDetails;
  final String instructions;
  final bool requiresProof;

  const PaymentMethodSnapshot({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.logoUrl,
    required this.providerName,
    required this.accountHolder,
    required this.accountIdentifier,
    required this.additionalDetails,
    required this.instructions,
    required this.requiresProof,
  });

  factory PaymentMethodSnapshot.fromJson(Map<String, dynamic> json) => PaymentMethodSnapshot(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? 'other',
        logoUrl: json['logoUrl']?.toString() ?? '',
        providerName: json['providerName']?.toString() ?? '',
        accountHolder: json['accountHolder']?.toString() ?? '',
        accountIdentifier: json['accountIdentifier']?.toString() ?? '',
        additionalDetails: json['additionalDetails']?.toString() ?? '',
        instructions: json['instructions']?.toString() ?? '',
        requiresProof: json['requiresProof'] == true,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'description': description,
        'category': category,
        'logoUrl': logoUrl,
        'providerName': providerName,
        'accountHolder': accountHolder,
        'accountIdentifier': accountIdentifier,
        'additionalDetails': additionalDetails,
        'instructions': instructions,
        'requiresProof': requiresProof,
      };
}

class CollectionPoint {
  final String? name;
  final String? address;
  final String? city;

  const CollectionPoint({this.name, this.address, this.city});

  CollectionPoint.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        address = json['address'] as String?,
        city = json['city'] as String?;

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'city': city,
      }..removeWhere((_, value) => value == null);

  String get formattedAddress => [address, city]
      .where((part) => part != null && part.trim().isNotEmpty)
      .join(', ');

  bool get isComplete =>
      name?.trim().isNotEmpty == true &&
      address?.trim().isNotEmpty == true &&
      city?.trim().isNotEmpty == true;
}

class ShippingAddress {
  String? phone;
  String? street;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  double? latitude;
  double? longitude;

  ShippingAddress({
    this.phone,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    street = json['street'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postalCode'];
    country = json['country'];
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['postalCode'] = postalCode;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  String get formattedAddress {
    final parts = [street, city, state, postalCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

class OrderTotal {
  double? subtotal;
  double? discount;
  double? total;

  OrderTotal({this.subtotal, this.discount, this.total});

  OrderTotal.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal']?.toDouble();
    discount = json['discount']?.toDouble();
    total = json['total']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['total'] = total;
    return data;
  }
}

class UserID {
  String? sId;
  String? name;

  UserID({this.sId, this.name});

  UserID.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class Items {
  String? productID;
  String? productName;
  int? quantity;
  double? price;
  String? variant;
  String? sId;

  Items({
    this.productID,
    this.productName,
    this.quantity,
    this.price,
    this.variant,
    this.sId,
  });

  Items.fromJson(Map<String, dynamic> json) {
    productID = json['productID'];
    productName = json['productName'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    variant = json['variant'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productID'] = productID;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['price'] = price;
    data['variant'] = variant;
    data['_id'] = sId;
    return data;
  }
}

class PaymentProof {
  String? imageUrl;
  bool available = false;
  String? uploadedAt;
  bool? verified;
  String? verifiedAt;

  PaymentProof({
    this.imageUrl,
    this.available = false,
    this.uploadedAt,
    this.verified,
    this.verifiedAt,
  });

  PaymentProof.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    available = json['available'] == true || (imageUrl?.isNotEmpty ?? false);
    uploadedAt = json['uploadedAt'];
    verified = json['verified'];
    verifiedAt = json['verifiedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['uploadedAt'] = uploadedAt;
    data['verified'] = verified;
    data['verifiedAt'] = verifiedAt;
    return data;
  }
}
