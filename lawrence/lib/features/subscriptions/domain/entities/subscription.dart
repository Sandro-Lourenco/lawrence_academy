class Subscription {
  final String id;
  final String studentId;
  final String courseId;
  final String provider;
  final String status;
  final double monthlyPrice;
  final String currency;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.provider,
    required this.status,
    required this.monthlyPrice,
    required this.currency,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active' || status == 'trialing';
  bool get isTrialing => status == 'trialing';
  bool get isCanceled =>
      canceledAt != null || cancelAtPeriodEnd || status == 'canceled';
  bool get isPastDue => status == 'past_due' || status == 'payment_failed';
  bool get isExpired => status == 'expired' || status == 'unpaid';

  bool get hasAccess =>
      isActive || (isCanceled && currentPeriodEnd.isAfter(DateTime.now()));
}
