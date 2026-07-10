import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

@immutable
class StudentSubscription {
  final String userId;
  final String status;
  final DateTime currentPeriodEnd;

  const StudentSubscription({
    required this.userId,
    required this.status,
    required this.currentPeriodEnd,
  });

  factory StudentSubscription.fromJson(Map<String, dynamic> json) {
    return StudentSubscription(
      userId: json['student_id'] as String,
      status: json['status'] as String? ?? 'inactive',
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
    );
  }

  /// Verifica se está em período de carência (past_due há menos de 5 dias)
  bool get isInGracePeriod {
    if (status != 'past_due') return false;
    final now = DateTime.now().toUtc();
    final difference = now.difference(currentPeriodEnd).inDays;
    return difference >= 0 && difference <= 5;
  }
}

final subscriptionFutureProvider = FutureProvider<StudentSubscription?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  try {
    final response = await client
        .from('subscriptions')
        .select('*')
        .eq('student_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return StudentSubscription.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
});
