import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/live_event.dart';

final livesProvider = FutureProvider<List<LiveEvent>>((ref) async {
  // Simulando carregamento via rede
  await Future.delayed(const Duration(seconds: 1));

  // Retorna uma lista de mocks para teste.
  // Em um ambiente real, buscaria de um repositório real.
  return [
    LiveEvent(
      id: 'live_1',
      title: 'Mentoria: Estratégias de Carreira em UI/UX',
      instructor: 'Lawrence',
      scheduledFor: DateTime.now().add(const Duration(days: 2, hours: 3)),
      durationMinutes: 90,
      status: 'scheduled',
      tag: 'Mentoria Premium',
    ),
    LiveEvent(
      id: 'live_2',
      title: 'Workshop: Acessibilidade Digital e WCAG',
      instructor: 'Lawrence',
      scheduledFor: DateTime.now().subtract(const Duration(minutes: 30)),
      durationMinutes: 120,
      status: 'live',
      tag: 'Workshop Ao Vivo',
    ),
    LiveEvent(
      id: 'live_3',
      title: 'Q&A: Respondendo dúvidas sobre Riverpod',
      instructor: 'Lawrence',
      scheduledFor: DateTime.now().subtract(const Duration(days: 3)),
      durationMinutes: 60,
      status: 'ended',
      tag: 'Tira-Dúvidas',
    ),
  ];
});
