import '../entities/live_event.dart';

abstract interface class LiveEventRepository {
  Future<List<LiveEvent>> listPublic();
  Future<List<LiveEvent>> listForTeacher();
  Future<LiveEvent> create(LiveEvent event);
  Future<LiveEvent> update(LiveEvent event);
  Future<void> delete(String eventId);
}
