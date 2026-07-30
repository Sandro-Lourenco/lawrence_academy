import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/live_event.dart';

final livesProvider = FutureProvider<List<LiveEvent>>((ref) async {
  // O contrato de leitura de lives ainda não existe no SERVICE_API.
  // Não exponha dados fictícios como se fossem uma agenda real.
  return const <LiveEvent>[];
});
