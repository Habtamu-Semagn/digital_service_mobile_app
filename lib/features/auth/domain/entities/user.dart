import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? fullNameAm;
  final String role;
  final String? phoneNumber;
  final String? preferredLanguage;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.fullNameAm,
    required this.role,
    this.phoneNumber,
    this.preferredLanguage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        fullNameAm,
        role,
        phoneNumber,
        preferredLanguage,
        createdAt,
      ];
}
