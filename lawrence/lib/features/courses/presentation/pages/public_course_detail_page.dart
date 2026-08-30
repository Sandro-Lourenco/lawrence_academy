import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../providers/course_detail_provider.dart';
import '../widgets/public_detail/public_course_detail_content.dart';

class PublicCourseDetailPage extends ConsumerWidget {
  const PublicCourseDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(courseDetailBySlugProvider(slug))
        .when(
          loading: () => const ColoredBox(
            color: PublicEditorialColors.ivory,
            child: SizedBox(
              height: 720,
              child: AppLoadingState(message: 'Carregando detalhes do curso'),
            ),
          ),
          error: (error, _) {
            final appError = AppError.fromException(error);
            return ColoredBox(
              color: PublicEditorialColors.ivory,
              child: SizedBox(
                height: 720,
                child: AppErrorState(
                  title: appError.title,
                  message: appError.message,
                  onRetry: () =>
                      ref.invalidate(courseDetailBySlugProvider(slug)),
                ),
              ),
            );
          },
          data: (course) => course == null
              ? const ColoredBox(
                  color: PublicEditorialColors.ivory,
                  child: SizedBox(
                    height: 620,
                    child: AppEmptyState(
                      title: 'Curso não encontrado',
                      description: 'Este curso não está disponível no momento.',
                    ),
                  ),
                )
              : SingleChildScrollView(
                  key: const PageStorageKey<String>('public-course-detail'),
                  primary: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: PublicCourseDetailContent(course: course),
                ),
        );
  }
}
