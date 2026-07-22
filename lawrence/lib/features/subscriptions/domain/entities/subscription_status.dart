import 'package:flutter/foundation.dart';

@immutable
class SubscriptionStatus {
  final String id;
  final String courseId;
  final String status;
  final DateTime? currentPeriodEnd;
  final bool hasAccess;
  final DateTime? gracePeriodEndsAt;

  final double monthlyPrice;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool cancelAtPeriodEnd; // Optional fallback

  const SubscriptionStatus({
    required this.id,
    required this.courseId,
    required this.status,
    this.currentPeriodEnd,
    required this.hasAccess,
    this.gracePeriodEndsAt,
    required this.monthlyPrice,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.cancelAtPeriodEnd = false,
  });

  bool get isCanceled => status == 'canceled' || cancelAtPeriodEnd;
  bool get isPastDue => status == 'past_due';
  bool get isExpired => status == 'expired' || status == 'canceled';
  bool get isTrialing => status == 'trialing';

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      status: json['status'] as String,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      hasAccess: json['has_access'] as bool,
      gracePeriodEndsAt: json['grace_period_ends_at'] != null
          ? DateTime.parse(json['grace_period_ends_at'] as String)
          : null,
      monthlyPrice: (json['monthly_price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }
}
