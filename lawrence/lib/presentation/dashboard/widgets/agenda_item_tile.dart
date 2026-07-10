import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';

class AgendaItemTile extends StatelessWidget {
  final String title;
  final String subtext;
  final bool isLive;
  final VoidCallback onTap;

  const AgendaItemTile({
    super.key,
    required this.title,
    required this.subtext,
    this.isLive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: LawrenceTheme.borderMist, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Barra vertical de destaque na esquerda
            Container(
              width: 3.5,
              height: 38,
              decoration: BoxDecoration(
                color: isLive ? LawrenceTheme.primary : LawrenceTheme.textSecondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: LawrenceTheme.surfaceTile1,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: LawrenceTheme.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            
            // Selo "+ AO VIVO" se for live
            if (isLive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LawrenceTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '+ AO VIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
