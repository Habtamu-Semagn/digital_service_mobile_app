import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? name; // Added to handle backend using 'name' instead of 'fullName'
  final String? fullNameAm;
  final String role;
  final String? phoneNumber;
  final String? preferredLanguage;
  final String? createdAt;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.name,
    this.fullNameAm,
    required this.role,
    this.phoneNumber,
    this.preferredLanguage,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      email: email ?? '',
      fullName: fullName ?? name ?? '',
      fullNameAm: fullNameAm,
      role: role,
      phoneNumber: phoneNumber,
      preferredLanguage: preferredLanguage,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      fullNameAm: user.fullNameAm,
      role: user.role,
      phoneNumber: user.phoneNumber,
      preferredLanguage: user.preferredLanguage,
      createdAt: user.createdAt.toIso8601String(),
    );
  }
}

@JsonSerializable()
class LoginResponse {
  final bool success;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  final String token;
  final String refreshToken;
  final UserModel user;

  LoginData({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}
