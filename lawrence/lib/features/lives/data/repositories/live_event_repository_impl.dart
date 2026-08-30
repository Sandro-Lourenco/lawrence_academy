import '../../../../core/network/network_client.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/repositories/live_event_repository.dart';

class LiveEventRepositoryImpl implements LiveEventRepository {
  const LiveEventRepositoryImpl(this._client);
  final NetworkClient _client;

  @override
  Future<List<LiveEvent>> listPublic() async {
    final response = await _client.get<List<dynamic>>('/api/v1/live-events');
    return (response.data ?? const [])
        .map((item) => LiveEvent.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<LiveEvent>> listForTeacher() async {
    final response = await _client.get<List<dynamic>>('/api/v1/teacher/live-events');
    return (response.data ?? const [])
        .map((item) => LiveEvent.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<LiveEvent> create(LiveEvent event) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/live-events', data: event.toInputJson());
    return LiveEvent.fromJson(response.data!);
  }

  @override
  Future<LiveEvent> update(LiveEvent event) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/teacher/live-events/${event.id}', data: event.toInputJson());
    return LiveEvent.fromJson(response.data!);
  }

  @override
  Future<void> delete(String eventId) async {
    await _client.delete('/api/v1/teacher/live-events/$eventId');
  }
}
