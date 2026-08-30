import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

enum StudentActionButtonVariant { primary, secondary, quiet }

/// Canonical action for the student experience.
///
/// The primary variant uses the canonical Lawrence wine action color.
class StudentActionButton extends StatefulWidget {
  const StudentActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.variant = StudentActionButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final StudentActionButtonVariant variant;

  @override
  State<StudentActionButton> createState() => _StudentActionButtonState();
}

class _StudentActionButtonState extends State<StudentActionButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.variant == StudentActionButtonVariant.primary;
    final quiet = widget.variant == StudentActionButtonVariant.quiet;
    final foreground = primary ? LawrenceColors.actionOnDark : scheme.onSurface;
    final primaryBackground = _pressed
        ? LawrenceColors.actionPrimaryPressed
        : _hovered
        ? LawrenceColors.actionPrimaryHover
        : LawrenceColors.actionPrimary;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final button = Semantics(
      button: true,
      enabled: _enabled,
      label: widget.loading ? '${widget.label}, carregando' : widget.label,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(
            0,
            _hovered && !_pressed ? -1 : 0,
            0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: _focused
                  ? (dark ? LawrenceColors.darkTextPrimary : scheme.primary)
                  : primary
                  ? primaryBackground
                  : scheme.outline,
              width: _focused ? 2 : 1,
            ),
            boxShadow: primary && _enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: _pressed ? .14 : (_hovered ? .30 : .20),
                      ),
                      blurRadius: _pressed ? 5 : (_hovered ? 16 : 10),
                      offset: Offset(0, _pressed ? 2 : 5),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: !_enabled
                    ? scheme.surfaceContainerHighest
                    : quiet
                    ? Colors.transparent
                    : primary
                    ? primaryBackground
                    : scheme.surface,
              ),
              child: InkWell(
                onTap: _enabled ? widget.onPressed : null,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 52,
                    minWidth: 48,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: widget.expand
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.loading)
                          SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(widget.icon, size: 19, color: foreground),
                        if (widget.loading || widget.icon != null)
                          const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _enabled
                                      ? foreground
                                      : scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .25,
                                ),
                          ),
                        ),
                        if (!widget.loading) ...[
                          const SizedBox(width: 18),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: _enabled
                                ? foreground
                                : scheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Compatibility alias while feature pages migrate to [StudentActionButton].
class CouturePrimaryButton extends StatelessWidget {
  const CouturePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) => StudentActionButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    loading: loading,
    expand: expand,
  );
}
