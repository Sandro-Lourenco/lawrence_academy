import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

enum SyncState {
  offline,
  reconnecting,
  syncing,
  synced,
  processingQueue,
  stopped,
  conflict,
  error,
}

class SyncStatusBanner extends StatelessWidget {
  final SyncState state;
  final String? message;

  const SyncStatusBanner({super.key, required this.state, this.message});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    IconData icon;
    String defaultMessage;

    switch (state) {
      case SyncState.offline:
        bgColor = LawrenceTheme.textSecondary.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.textSecondary;
        icon = Icons.wifi_off;
        defaultMessage = 'Sem conexão com a internet';
        break;
      case SyncState.reconnecting:
        bgColor = LawrenceTheme.warning.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.warning;
        icon = Icons.sensors;
        defaultMessage = 'Reconectando...';
        break;
      case SyncState.syncing:
        bgColor = LawrenceTheme.primary.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.primary;
        icon = Icons.sync;
        defaultMessage = 'Sincronizando dados...';
        break;
      case SyncState.synced:
        bgColor = LawrenceTheme.success.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.success;
        icon = Icons.cloud_done;
        defaultMessage = 'Tudo atualizado';
        break;
      case SyncState.processingQueue:
        bgColor = LawrenceTheme.primary.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.primary;
        icon = Icons.queue;
        defaultMessage = 'Processando fila pendente...';
        break;
      case SyncState.stopped:
        bgColor = LawrenceTheme.warning.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.warning;
        icon = Icons.pause_circle_outline;
        defaultMessage = 'Sincronização pausada';
        break;
      case SyncState.conflict:
        bgColor = LawrenceTheme.warning.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.warning;
        icon = Icons.sync_problem;
        defaultMessage = 'Conflito de sincronização';
        break;
      case SyncState.error:
        bgColor = LawrenceTheme.danger.withValues(alpha: 0.1);
        fgColor = LawrenceTheme.danger;
        icon = Icons.error_outline;
        defaultMessage = 'Erro na sincronização';
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? defaultMessage,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 13,
              ),
            ),
          ),
          if (state == SyncState.syncing ||
              state == SyncState.reconnecting ||
              state == SyncState.processingQueue)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            ),
        ],
      ),
    );
  }
}
