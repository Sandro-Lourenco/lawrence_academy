import 'package:flutter/material.dart';

import '../../../../design_system/widgets/status_badge.dart';
import '../../domain/entities/activity.dart';

class ActivityStatusPresentation {
  final String label;
  final IconData icon;
  final AppStatusTone tone;

  const ActivityStatusPresentation(this.label, this.icon, this.tone);
}

ActivityStatusPresentation activityStatusPresentation(ActivityStatus status) {
  return switch (status) {
    ActivityStatus.pending => const ActivityStatusPresentation(
      'Não iniciado',
      Icons.schedule_outlined,
      AppStatusTone.warning,
    ),
    ActivityStatus.inProgress => const ActivityStatusPresentation(
      'Em andamento',
      Icons.play_circle_outline_rounded,
      AppStatusTone.info,
    ),
    ActivityStatus.submitted => const ActivityStatusPresentation(
      'Enviado',
      Icons.upload_file_rounded,
      AppStatusTone.practice,
    ),
    ActivityStatus.graded => const ActivityStatusPresentation(
      'Avaliado',
      Icons.check_circle_outline_rounded,
      AppStatusTone.success,
    ),
    ActivityStatus.overdue => const ActivityStatusPresentation(
      'Atrasado',
      Icons.error_outline_rounded,
      AppStatusTone.danger,
    ),
  };
}
