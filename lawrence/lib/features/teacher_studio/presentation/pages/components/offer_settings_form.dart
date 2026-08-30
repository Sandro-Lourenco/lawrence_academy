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
  Widget build(BuildContext context) => Theme(
    data: _offerTheme(context),
    child: Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1040;
          final form = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow('FASE 2 DE 5'),
              const SizedBox(height: 8),
              Text(
                'Desenhe uma oferta irresistível.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Defina como o curso será vendido e o que o aluno recebe. Você pode alterar tudo antes de publicar.',
                style: TextStyle(
                  color: Color(0xFFB8C1DD),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              _SectionCard(
                icon: Icons.sell_outlined,
                title: 'Modelo da oferta',
                subtitle:
                    'Escolha uma opção. Não há cobrança até a publicação.',
                child: Row(
                  children: [
                    Expanded(
                      child: _ChoiceCard(
                        selected: !isFree,
                        icon: Icons.autorenew_rounded,
                        title: 'Assinatura mensal',
                        description: 'Receita recorrente por aluno.',
                        onTap: () => onFreeChanged(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChoiceCard(
                        selected: isFree,
                        icon: Icons.redeem_outlined,
                        title: 'Curso gratuito',
                        description: 'Acesso sem cobrança.',
                        onTap: () => onFreeChanged(true),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFree) ...[
                const SizedBox(height: LawrenceSpacing.md),
                _SectionCard(
                  icon: Icons.payments_outlined,
                  title: 'Preço e promoção',
                  subtitle: 'Use valores simples e transparentes para o aluno.',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: monthlyPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Mensalidade',
                          prefixText: 'R\$ ',
                          suffixText: '/ mês',
                          helperText:
                              'Valor recorrente cobrado por este curso.',
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
                          prefixText: 'R\$ ',
                          suffixText: '/ mês',
                          helperText:
                              'Deixe vazio se não houver campanha ativa.',
                        ),
                        onChanged: (_) => onChanged(),
                        validator: _validatePromotion,
                      ),
                      if (promotionalPriceController.text
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: LawrenceSpacing.md),
                        _PromotionDates(
                          startsAt: promotionStartsAt,
                          endsAt: promotionEndsAt,
                          onStart: () => _pickDate(
                            context,
                            promotionStartsAt,
                            onPromotionStartsChanged,
                          ),
                          onEnd: () => _pickDate(
                            context,
                            promotionEndsAt,
                            onPromotionEndsChanged,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: LawrenceSpacing.md),
              _SectionCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Experiência incluída',
                subtitle:
                    'Ative apenas o que fará parte desta primeira versão.',
                child: Column(
                  children: [
                    _FeatureSwitch(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Certificado de conclusão',
                      subtitle: 'Liberado conforme progresso e aprovação.',
                      value: certificateEnabled,
                      onChanged: onCertificateChanged,
                    ),
                    const Divider(height: 1),
                    _FeatureSwitch(
                      icon: Icons.star_outline_rounded,
                      title: 'Avaliações do curso',
                      subtitle:
                          'Alunos elegíveis podem compartilhar sua experiência.',
                      value: reviewsEnabled,
                      onChanged: onReviewsChanged,
                    ),
                    const Divider(height: 1),
                    _FeatureSwitch(
                      icon: Icons.forum_outlined,
                      title: 'Comentários nas aulas',
                      subtitle:
                          'Cria espaço para dúvidas e troca entre alunos.',
                      value: commentsEnabled,
                      onChanged: onCommentsChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LawrenceSpacing.md),
              _SectionCard(
                icon: Icons.visibility_outlined,
                title: 'Descoberta e acesso',
                subtitle: 'Controle onde o curso aparece depois da publicação.',
                child: DropdownButtonFormField<String>(
                  value: visibility,
                  decoration: const InputDecoration(
                    labelText: 'Visibilidade',
                    prefixIcon: Icon(Icons.language_rounded),
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
              ),
            ],
          );

          return Column(
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: form),
                    const SizedBox(width: LawrenceSpacing.xl),
                    SizedBox(
                      width: 320,
                      child: _OfferPreview(
                        isFree: isFree,
                        monthlyPriceController: monthlyPriceController,
                        promotionalPriceController: promotionalPriceController,
                        certificateEnabled: certificateEnabled,
                        reviewsEnabled: reviewsEnabled,
                        commentsEnabled: commentsEnabled,
                        visibility: visibility,
                      ),
                    ),
                  ],
                )
              else ...[
                form,
                const SizedBox(height: LawrenceSpacing.lg),
                _OfferPreview(
                  isFree: isFree,
                  monthlyPriceController: monthlyPriceController,
                  promotionalPriceController: promotionalPriceController,
                  certificateEnabled: certificateEnabled,
                  reviewsEnabled: reviewsEnabled,
                  commentsEnabled: commentsEnabled,
                  visibility: visibility,
                ),
              ],
              const SizedBox(height: LawrenceSpacing.xl),
              _BottomActions(
                isSaving: isSaving,
                onBack: onBack,
                onSave: onSave,
              ),
            ],
          );
        },
      ),
    ),
  );

  ThemeData _offerTheme(BuildContext context) {
    final base = Theme.of(context);
    const text = Color(0xFFF6F7FF);
    const muted = Color(0xFFB8C1DD);
    const border = Color(0x406B4A55);
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: const Color(0xFFA63B5E),
        surface: const Color(0xFF11172D),
        onSurface: text,
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      dividerColor: Colors.white.withValues(alpha: .12),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFF8290AD),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF6B1328)
              : const Color(0xFF28324F),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xB20A1022),
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: Color(0xFF7885A5)),
        helperStyle: const TextStyle(color: Color(0xFF8F9AB7)),
        prefixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFA63B5E), width: 2),
        ),
      ),
    );
  }

  String? _validatePromotion(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regular = _money(monthlyPriceController.text);
    final promotional = _money(value);
    if (promotional == null || promotional < 0) {
      return 'Informe um preço promocional válido.';
    }
    if (regular != null && promotional >= regular) {
      return 'A promoção deve ser menor que a mensalidade.';
    }
    if (promotionStartsAt == null || promotionEndsAt == null) {
      return 'Defina o início e o fim da promoção.';
    }
    return null;
  }

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
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xCC2C111B),
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Color(0x33A63B5E)),
      borderRadius: BorderRadius.circular(22),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1328).withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFFA63B5E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB8C1DD),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          child,
        ],
      ),
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0x66811D3B) : const Color(0x99181315),
          border: Border.all(
            color: selected ? const Color(0xFFA63B5E) : const Color(0x406B4A55),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? const Color(0xFFA63B5E)
                      : const Color(0xFF8290AD),
                ),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? const Color(0xFFA63B5E)
                      : const Color(0xFF8290AD),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Color(0xFFB8C1DD), fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FeatureSwitch extends StatelessWidget {
  const _FeatureSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    minTileHeight: 72,
    contentPadding: EdgeInsets.zero,
    secondary: Icon(
      icon,
      color: value ? const Color(0xFFA63B5E) : const Color(0xFF8290AD),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFFB8C1DD))),
    value: value,
    onChanged: onChanged,
  );
}

class _PromotionDates extends StatelessWidget {
  const _PromotionDates({
    required this.startsAt,
    required this.endsAt,
    required this.onStart,
    required this.onEnd,
  });

  final DateTime? startsAt;
  final DateTime? endsAt;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _DateButton(label: 'Início', value: startsAt, onTap: onStart),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _DateButton(label: 'Fim', value: endsAt, onTap: onEnd),
      ),
    ],
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.calendar_today_outlined, size: 18),
    label: Text('$label: ${_date(value)}'),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      alignment: Alignment.centerLeft,
    ),
  );

  static String _date(DateTime? value) => value == null
      ? 'Selecionar'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _OfferPreview extends StatelessWidget {
  const _OfferPreview({
    required this.isFree,
    required this.monthlyPriceController,
    required this.promotionalPriceController,
    required this.certificateEnabled,
    required this.reviewsEnabled,
    required this.commentsEnabled,
    required this.visibility,
  });

  final bool isFree;
  final TextEditingController monthlyPriceController;
  final TextEditingController promotionalPriceController;
  final bool certificateEnabled;
  final bool reviewsEnabled;
  final bool commentsEnabled;
  final String visibility;

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: monthlyPriceController,
    builder: (context, value, child) => ValueListenableBuilder<TextEditingValue>(
      valueListenable: promotionalPriceController,
      builder: (context, promotionalValue, promotionalChild) {
        final regular = monthlyPriceController.text.trim().isEmpty
            ? '—'
            : monthlyPriceController.text.trim();
        final promotional = promotionalPriceController.text.trim();
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A1836), Color(0xFF32206F)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30071833),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF86C5FF),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PRÉVIA DA OFERTA',
                      style: TextStyle(
                        color: Color(0xFFBBDFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const Text(
                  'Seu curso',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                if (isFree)
                  const Text(
                    'Gratuito',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else ...[
                  if (promotional.isNotEmpty)
                    Text(
                      'R\$ $regular',
                      style: const TextStyle(
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'R\$ ${promotional.isNotEmpty ? promotional : regular}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: ' / mês',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
                const SizedBox(height: 22),
                _PreviewLine(
                  icon: Icons.language_rounded,
                  text: _visibilityLabel(visibility),
                ),
                if (certificateEnabled)
                  const _PreviewLine(
                    icon: Icons.workspace_premium_outlined,
                    text: 'Certificado incluído',
                  ),
                if (reviewsEnabled)
                  const _PreviewLine(
                    icon: Icons.star_outline_rounded,
                    text: 'Avaliações habilitadas',
                  ),
                if (commentsEnabled)
                  const _PreviewLine(
                    icon: Icons.forum_outlined,
                    text: 'Comunidade nas aulas',
                  ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B1328),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isFree ? 'Começar agora' : 'Assinar este curso',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Simulação visual. Nenhuma cobrança será criada nesta etapa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  static String _visibilityLabel(String value) => switch (value) {
    'unlisted' => 'Disponível somente por link',
    'private' => 'Acesso privado',
    _ => 'Visível no catálogo',
  };
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF8DC8FF), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isSaving,
    required this.onBack,
    required this.onSave,
  });
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xE62C111B),
      border: Border.all(color: const Color(0x33A63B5E)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14071833),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Voltar'),
        ),
        const Spacer(),
        const Flexible(
          child: Text(
            'Alterações salvas como rascunho',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0xFFB8C1DD), fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
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
          label: Text(isSaving ? 'Salvando…' : 'Salvar e continuar'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6B1328),
            foregroundColor: Colors.white,
            minimumSize: const Size(180, 52),
          ),
        ),
      ],
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFFA63B5E),
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
    ),
  );
}
