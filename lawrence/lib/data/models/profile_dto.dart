import 'package:flutter/foundation.dart';

@immutable
class Profile {
  final String id;
  final String fullName;
  final String? referredByCode;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.referredByCode,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      referredByCode: json['referred_by_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'referred_by_code': referredByCode,
    'created_at': createdAt?.toIso8601String(),
  };
}
