import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/activity.dart';
import 'activities_controller.dart';

Activity? findAuthorizedProject(Iterable<Activity> activities, String id) {
  for (final activity in activities) {
    if (activity.id == id && activity.type == ActivityType.project) {
      return activity;
    }
  }
  return null;
}

final projectDetailProvider = Provider.family<AsyncValue<Activity?>, String>((
  ref,
  projectId,
) {
  return ref
      .watch(activitiesNotifierProvider)
      .whenData((items) => findAuthorizedProject(items, projectId));
});
