import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

class StudentPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  const StudentPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ÁREA DE ESTUDOS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.1,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(child: leading),
              ),
              const SizedBox(width: LawrenceSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.displaySmall
                                : Theme.of(context).textTheme.displayMedium)
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                              height: .96,
                            ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ],
    );

    if (actions.isEmpty) return Semantics(header: true, child: titleBlock);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackActions = constraints.maxWidth < 620;
        return Semantics(
          header: true,
          child: Flex(
            direction: stackActions ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: stackActions
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              if (stackActions) titleBlock else Expanded(child: titleBlock),
              SizedBox(
                width: stackActions ? 0 : LawrenceSpacing.lg,
                height: stackActions ? LawrenceSpacing.md : 0,
              ),
              Wrap(
                spacing: LawrenceSpacing.sm,
                runSpacing: LawrenceSpacing.sm,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          ),
        );
      },
    );
  }
}

class StudentSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StudentSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: LawrenceSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: LawrenceColors.actionPrimary,
                ),
                child: Text(actionLabel!.toUpperCase()),
              ),
          ],
        ),
      ),
    );
  }
}
