import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/service_repositories.dart';

final courseTrailerStreamProvider = FutureProvider.autoDispose
    .family<String, String>((ref, courseId) async {
      return ref
          .watch(courseTrailerRepositoryProvider)
          .fetchStreamUrl(courseId);
    });
