import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

@immutable
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super([]) {
    _fetchNotifications();
    _subscribeToNotifications();
  }

  Future<void> _fetchNotifications() async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await client
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
          
      final data = response as List? ?? [];
      state = data.map((json) => AppNotification.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Falha silenciosa
    }
  }

  void _subscribeToNotifications() {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    // Escutar eventos de novas notificações em tempo real
    client
        .channel('public:notifications:user_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            _fetchNotifications(); // Recarrega do banco quando atualizado
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    final client = ref.read(supabaseClientProvider);
    try {
      await client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
          
      state = state.map((n) {
        if (n.id == notificationId) {
          return AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            read: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
    } catch (e) {
      // Ignorar erro
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier(ref);
});
