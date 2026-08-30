import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../providers/feedback_providers.dart';

class CourseReviewPage extends ConsumerStatefulWidget {
  const CourseReviewPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseReviewPage> createState() => _CourseReviewPageState();
}

class _CourseReviewPageState extends ConsumerState<CourseReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _comment = TextEditingController();
  int _rating = 5;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(courseCompletionRepositoryProvider)
          .submitReview(
            courseId: widget.courseId,
            rating: _rating,
            title: _title.text.trim(),
            comment: _comment.text.trim(),
          );
      ref.invalidate(feedbacksProvider);
      ref.invalidate(courseCompletionProvider(widget.courseId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Avaliação publicada. Obrigado por compartilhar sua experiência!',
          ),
        ),
      );
      context.go('/dashboard/feedbacks');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => StudentPageScaffold(
    title: 'Avalie sua experiência',
    subtitle:
        'Seu certificado já foi liberado. Agora compartilhe sua experiência com a comunidade Lawrence.',
    maxContentWidth: 760,
    body: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                tooltip: '${index + 1} estrelas',
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Título da avaliação'),
            validator: (value) =>
                (value?.trim().length ?? 0) < 2 ? 'Escreva um título.' : null,
          ),
          const SizedBox(height: LawrenceSpacing.md),
          TextFormField(
            controller: _comment,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Conte como foi sua experiência',
            ),
            validator: (value) => (value?.trim().length ?? 0) < 10
                ? 'Escreva pelo menos 10 caracteres.'
                : null,
          ),
          const SizedBox(height: LawrenceSpacing.xl),
          CouturePrimaryButton(
            label: 'PUBLICAR AVALIAÇÃO',
            icon: Icons.workspace_premium_outlined,
            loading: _saving,
            expand: true,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    ),
  );
}
