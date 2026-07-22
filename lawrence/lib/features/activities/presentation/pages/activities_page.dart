import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../controllers/activities_controller.dart';
import '../../domain/entities/activity.dart';

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesNotifierProvider);

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      body: activitiesAsync.when(
        loading: () => const AppLoadingState(),
        error: (err, stack) => AppErrorState(
          message: "Erro ao carregar atividades.",
          onRetry: () =>
              ref.read(activitiesNotifierProvider.notifier).loadActivities(),
        ),
        data: (activities) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),

            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    "Minhas Atividades",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: LawrenceColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Acompanhe seus prazos e feedbacks.",
                    style: TextStyle(
                      fontSize: 15,
                      color: LawrenceColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),

            if (activities.isEmpty)
              const SliverFillRemaining(
                child: AppEmptyState(
                  title: "Tudo em dia!",
                  description:
                      "Você não possui atividades pendentes no momento.",
                  icon: Icons.check_circle_outline_rounded,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildActivityCard(context, activity),
                    );
                  }, childCount: activities.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.72),
            child: const Center(
              child: Text(
                "ATIVIDADES",
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: LawrenceColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final statusColor = _getStatusColor(activity.status);
    final deadlineStr = activity.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(activity.deadline!)
        : "Sem prazo";

    return LiquidGlassCard(
      onTap: () {
        // Navegar para detalhes futuramente
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(activity.type),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: LawrenceColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activity.grade != null)
                      Text(
                        activity.grade!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: LawrenceColors.accentGold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.courseName,
                  style: TextStyle(
                    fontSize: 13,
                    color: LawrenceColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: LawrenceColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadlineStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: LawrenceColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusLabel(activity.status).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return Icons.quiz_outlined;
      case ActivityType.essay:
        return Icons.edit_note_rounded;
      case ActivityType.trueFalse:
        return Icons.checklist_rtl_rounded;
      case ActivityType.project:
        return Icons.architecture_rounded;
      case ActivityType.upload:
        return Icons.upload_file_rounded;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return LawrenceColors.primary;
      case ActivityStatus.inProgress:
        return LawrenceColors.info;
      case ActivityStatus.submitted:
        return Colors.orange;
      case ActivityStatus.graded:
        return LawrenceColors.success;
      case ActivityStatus.overdue:
        return LawrenceColors.danger;
    }
  }

  String _getStatusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return "Pendente";
      case ActivityStatus.inProgress:
        return "Em andamento";
      case ActivityStatus.submitted:
        return "Enviada";
      case ActivityStatus.graded:
        return "Corrigida";
      case ActivityStatus.overdue:
        return "Atrasada";
    }
  }
}
