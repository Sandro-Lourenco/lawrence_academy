import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';

class EventsBanner extends StatelessWidget {
  const EventsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir agenda de eventos da Lawrence Academy',
      child: InkWell(
        key: const Key('dashboard-events-link'),
        onTap: () => context.go('/dashboard/events'),
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          decoration: BoxDecoration(
            color: LawrenceColors.brandNavy,
            border: const Border(
              left: BorderSide(color: LawrenceColors.actionPrimary, width: 5),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AGENDA CULTURAL · CADERNO DE ENCONTROS',
                    style: TextStyle(
                      color: LawrenceColors.actionOnDark,
                      letterSpacing: 1,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.xs),
                  Text(
                    'A escola continua ao vivo.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.xs),
                  const Text(
                    'Consulte a agenda de conversas, workshops e encontros.',
                    style: TextStyle(
                      color: LawrenceColors.canvasParchment,
                      fontSize: 15,
                    ),
                  ),
                ],
              );
              final action = OutlinedButton.icon(
                onPressed: () => context.go('/dashboard/events'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.event_outlined),
                label: const Text('ABRIR AGENDA'),
              );
              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        text,
                        const SizedBox(height: LawrenceSpacing.md),
                        action,
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(
                          Icons.live_tv_outlined,
                          color: Colors.white,
                          size: 46,
                        ),
                        const SizedBox(width: LawrenceSpacing.lg),
                        Expanded(child: text),
                        const SizedBox(width: LawrenceSpacing.lg),
                        action,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
