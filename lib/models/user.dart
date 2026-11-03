class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? password;
  bool emailVerified;
  bool phoneVerified;
  String? verificationCode;
  String? codeExpires;
  String? recoveryEmail;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? deviceToken;
  String? lastLoginAt;

  User({
    this.sId,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.verificationCode,
    this.codeExpires,
    this.recoveryEmail,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.deviceToken,
    this.lastLoginAt,
  });

  User.fromJson(Map<String, dynamic> json)
      : sId = json['_id'],
        name = json['name'],
        email = json['email'],
        phone = json['phone'],
        password = json['password'],
        emailVerified = json['emailVerified'] ?? false,
        phoneVerified = json['phoneVerified'] ?? false,
        verificationCode = json['verificationCode'],
        codeExpires = json['codeExpires'],
        recoveryEmail = json['recoveryEmail'],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        iV = json['__v'],
        deviceToken = json['deviceToken'],
        lastLoginAt = json['lastLoginAt'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['password'] = password;
    data['emailVerified'] = emailVerified;
    data['phoneVerified'] = phoneVerified;
    data['verificationCode'] = verificationCode;
    data['codeExpires'] = codeExpires;
    data['recoveryEmail'] = recoveryEmail;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['deviceToken'] = deviceToken;
    data['lastLoginAt'] = lastLoginAt;
    return data;
  }

  // Helper method to check if user data is complete
  bool get isComplete => name != null && name!.isNotEmpty;

  // Helper method to get user identifier for persistence
  String get userIdentifier {
    return email ?? phone ?? sId ?? 'unknown';
  }
}
