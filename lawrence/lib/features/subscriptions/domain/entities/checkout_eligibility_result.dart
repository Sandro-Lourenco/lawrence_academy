import 'package:flutter/foundation.dart';

@immutable
class CheckoutEligibilityResult {
  final bool canPurchase;
  final bool hasAccess;
  final String? reasonCode;
  final String? message;
  final String? subscriptionStatus;
  final String courseId;

  const CheckoutEligibilityResult({
    required this.canPurchase,
    required this.hasAccess,
    this.reasonCode,
    this.message,
    this.subscriptionStatus,
    required this.courseId,
  });

  factory CheckoutEligibilityResult.fromJson(Map<String, dynamic> json) {
    return CheckoutEligibilityResult(
      canPurchase: json['can_purchase'] as bool,
      hasAccess: json['has_access'] as bool,
      reasonCode: json['reason_code'] as String?,
      message: json['message'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      courseId: json['course_id'] as String,
    );
  }
}
