import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';

class OfferSettingsForm extends StatelessWidget {
  const OfferSettingsForm({
    super.key,
    required this.formKey,
    required this.monthlyPriceController,
    required this.promotionalPriceController,
    required this.isFree,
    required this.promotionStartsAt,
    required this.promotionEndsAt,
    required this.certificateEnabled,
    required this.reviewsEnabled,
    required this.commentsEnabled,
    required this.visibility,
    required this.isSaving,
    required this.onFreeChanged,
    required this.onPromotionStartsChanged,
    required this.onPromotionEndsChanged,
    required this.onCertificateChanged,
    required this.onReviewsChanged,
    required this.onCommentsChanged,
    required this.onVisibilityChanged,
    required this.onChanged,
    required this.onBack,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController monthlyPriceController;
  final TextEditingController promotionalPriceController;
  final bool isFree;
  final DateTime? promotionStartsAt;
  final DateTime? promotionEndsAt;
  final bool certificateEnabled;
  final bool reviewsEnabled;
  final bool commentsEnabled;
  final String visibility;
  final bool isSaving;
  final ValueChanged<bool> onFreeChanged;
  final ValueChanged<DateTime?> onPromotionStartsChanged;
  final ValueChanged<DateTime?> onPromotionEndsChanged;
  final ValueChanged<bool> onCertificateChanged;
  final ValueChanged<bool> onReviewsChanged;
  final ValueChanged<bool> onCommentsChanged;
  final ValueChanged<String> onVisibilityChanged;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < LawrenceBreakpoints.tablet;
        return Container(
          padding: EdgeInsets.all(
            compact ? LawrenceSpacing.md : LawrenceSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: LawrenceColors.canvas,
            border: Border.all(color: LawrenceColors.borderMist),
            borderRadius: BorderRadius.circular(LawrenceRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Apresentação e oferta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: LawrenceColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              const Text(
                'Fase 2 de 5 · Configure a oferta e como o curso será encontrado.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              const _SectionTitle('Oferta'),
              const SizedBox(height: LawrenceSpacing.md),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Gratuito'),
                    icon: Icon(Icons.volunteer_activism_outlined),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Assinatura mensal'),
                    icon: Icon(Icons.credit_card_outlined),
                  ),
                ],
                selected: {isFree},
                onSelectionChanged: (selection) =>
                    onFreeChanged(selection.first),
              ),
              const SizedBox(height: LawrenceSpacing.md),
              if (!isFree) ...[
                TextFormField(
                  controller: monthlyPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor mensal (R\$)',
                    helperText:
                        'O backend valida o valor antes de salvar ou publicar.',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) {
                    final price = _money(value);
                    return price == null || price <= 0
                        ? 'Informe um valor mensal maior que zero.'
                        : null;
                  },
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: promotionalPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Preço promocional (opcional)',
                    helperText: 'Deve ser menor que o valor mensal.',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final regular = _money(monthlyPriceController.text);
                    final promotional = _money(value);
                    if (promotional == null || promotional < 0) {
                      return 'Informe um preço promocional válido.';
                    }
                    if (regular != null && promotional >= regular) {
                      return 'O preço promocional deve ser menor que o valor mensal.';
                    }
                    if (promotionStartsAt == null || promotionEndsAt == null) {
                      return 'Defina o início e o fim da promoção.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: LawrenceSpacing.md),
                Wrap(
                  spacing: LawrenceSpacing.sm,
                  runSpacing: LawrenceSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(
                        context,
                        promotionStartsAt,
                        onPromotionStartsChanged,
                      ),
                      icon: const Icon(Icons.event_outlined),
                      label: Text('Início: ${_dateLabel(promotionStartsAt)}'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(
                        context,
                        promotionEndsAt,
                        onPromotionEndsChanged,
                      ),
                      icon: const Icon(Icons.event_available_outlined),
                      label: Text('Fim: ${_dateLabel(promotionEndsAt)}'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: LawrenceSpacing.xl),
              const _SectionTitle('Experiência do aluno'),
              const SizedBox(height: LawrenceSpacing.sm),
              _settingSwitch(
                title: 'Certificado',
                subtitle:
                    'A emissão ainda respeita as regras de conclusão e aprovação.',
                value: certificateEnabled,
                onChanged: onCertificateChanged,
              ),
              _settingSwitch(
                title: 'Avaliações do curso',
                subtitle: 'Permite que alunos elegíveis avaliem o curso.',
                value: reviewsEnabled,
                onChanged: onReviewsChanged,
              ),
              _settingSwitch(
                title: 'Comentários nas aulas',
                subtitle:
                    'Ativa a participação dos alunos quando o recurso estiver disponível.',
                value: commentsEnabled,
                onChanged: onCommentsChanged,
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              const _SectionTitle('Visibilidade'),
              const SizedBox(height: LawrenceSpacing.md),
              DropdownButtonFormField<String>(
                value: visibility,
                decoration: const InputDecoration(
                  labelText: 'Quem pode encontrar o curso?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'public',
                    child: Text('Público — aparece no catálogo'),
                  ),
                  DropdownMenuItem(
                    value: 'unlisted',
                    child: Text('Não listado — somente com link'),
                  ),
                  DropdownMenuItem(
                    value: 'private',
                    child: Text('Privado — acesso restrito'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onVisibilityChanged(value);
                },
              ),
              const SizedBox(height: LawrenceSpacing.md),
              Container(
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                decoration: BoxDecoration(
                  color: LawrenceColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(LawrenceRadii.control),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: LawrenceColors.info,
                    ),
                    SizedBox(width: LawrenceSpacing.sm),
                    Expanded(
                      child: Text(
                        'Curso em destaque é uma decisão editorial da Lawrence Academy e não pode ser alterado pelo professor.',
                        style: TextStyle(color: LawrenceColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                spacing: LawrenceSpacing.md,
                runSpacing: LawrenceSpacing.sm,
                children: [
                  TextButton(onPressed: onBack, child: const Text('Voltar')),
                  FilledButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(isSaving ? 'Salvando' : 'Salvar e continuar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _settingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: const TextStyle(
        color: LawrenceColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: LawrenceColors.textSecondary),
    ),
    value: value,
    onChanged: onChanged,
  );

  Future<void> _pickDate(
    BuildContext context,
    DateTime? current,
    ValueChanged<DateTime?> callback,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) callback(date);
  }

  static double? _money(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  static String _dateLabel(DateTime? value) => value == null
      ? 'Selecionar'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: LawrenceColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
