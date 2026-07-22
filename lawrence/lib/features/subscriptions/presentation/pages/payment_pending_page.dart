import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/subscriptions_controller.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import 'dart:async';

class PaymentPendingPage extends ConsumerStatefulWidget {
  final String sessionId;

  const PaymentPendingPage({super.key, required this.sessionId});

  @override
  ConsumerState<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends ConsumerState<PaymentPendingPage> {
  Timer? _pollingTimer;
  int _attempts = 0;
  static const int _maxAttempts = 15; // 15 attempts * 2s = 30s max polling

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Check immediately, then poll
    _checkStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    _attempts++;

    try {
      final status = await ref
          .read(subscriptionsControllerProvider.notifier)
          .getCheckoutStatus(widget.sessionId);

      if (!mounted) return;

      if (status == 'paid' || status == 'complete') {
        _pollingTimer?.cancel();
        _showSuccessAndRedirect();
      } else if (status == 'expired' ||
          status == 'canceled' ||
          status == 'cancelled' ||
          status == 'failed' ||
          status == 'unpaid') {
        _pollingTimer?.cancel();
        _showErrorAndRedirect('Pagamento cancelado ou expirado.');
      } else if (_attempts >= _maxAttempts) {
        _pollingTimer?.cancel();
        _showErrorAndRedirect(
          'Tempo limite excedido aguardando confirmação. Verifique suas faturas em instantes.',
        );
      }
      // if 'pending' or 'open', keep polling
    } catch (e) {
      if (!mounted) return;
      _pollingTimer?.cancel();
      _showErrorAndRedirect('Erro ao verificar status: $e');
    }
  }

  void _showSuccessAndRedirect() {
    // Invalidate subscriptions so it fetches the new active one
    ref.invalidate(subscriptionsControllerProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pagamento confirmado com sucesso!'),
        backgroundColor: LawrenceColors.success,
      ),
    );
    context.go('/dashboard/subscriptions');
  }

  void _showErrorAndRedirect(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: LawrenceColors.danger),
    );
    context.go('/dashboard/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawrenceColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingState(message: 'Confirmando seu pagamento...'),
            const SizedBox(height: 16),
            Text(
              'Aguardando webhook do Stripe. Tentativa $_attempts de $_maxAttempts.',
              style: const TextStyle(color: LawrenceColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
