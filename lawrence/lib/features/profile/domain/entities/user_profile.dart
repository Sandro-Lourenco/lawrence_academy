class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.referredBy,
  });

  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? referredBy;
}
