import '../../domain/entities/subscription.dart';

class SubscriptionModel {
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

  SubscriptionModel({
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

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String,
      provider: json['provider'] as String? ?? 'stripe',
      status: json['status'] as String,
      monthlyPrice: double.tryParse(json['monthly_price'].toString()) ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      currentPeriodStart: DateTime.parse(
        json['current_period_start'] as String,
      ),
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      canceledAt: json['canceled_at'] != null
          ? DateTime.parse(json['canceled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Subscription toEntity() {
    return Subscription(
      id: id,
      studentId: studentId,
      courseId: courseId,
      provider: provider,
      status: status,
      monthlyPrice: monthlyPrice,
      currency: currency,
      currentPeriodStart: currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd,
      cancelAtPeriodEnd: cancelAtPeriodEnd,
      canceledAt: canceledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
