import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

class LiveStatusBadge extends StatelessWidget {
  final String status; // 'live', 'scheduled', 'ended'

  const LiveStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    String label;
    IconData icon;
    bool isPulsing = false;

    switch (status.toLowerCase()) {
      case 'live':
        bgColor = LawrenceTheme.danger.withValues(alpha: 0.15);
        fgColor = LawrenceTheme.danger;
        label = 'AO VIVO';
        icon = Icons.sensors;
        isPulsing = true;
        break;
      case 'scheduled':
        bgColor = LawrenceTheme.primary.withValues(alpha: 0.15);
        fgColor = LawrenceTheme.primary;
        label = 'AGENDADA';
        icon = Icons.event;
        break;
      case 'ended':
      default:
        bgColor = LawrenceTheme.textSecondary.withValues(alpha: 0.15);
        fgColor = LawrenceTheme.textSecondary;
        label = 'ENCERRADA';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w800,
              fontFamily: 'Outfit',
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
          if (isPulsing) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: fgColor, shape: BoxShape.circle),
            ), // Basic pulse visual indicator (can be animated later)
          ],
        ],
      ),
    );
  }
}
