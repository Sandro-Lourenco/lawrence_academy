import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications_provider.dart';
import '../../core/auth_provider.dart';
import '../theme.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget body;

  const DashboardLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => !n.read).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: LiquidTheme.glassBlur(),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: LiquidTheme.background.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(
                    color: LiquidTheme.textPrimary.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand / Logo da Lawrence Academy
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LiquidTheme.auraGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "L",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "LAWRENCE ACADEMY",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 15,
                            color: LiquidTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Ícones de Notificação & Perfil
                    Row(
                      children: [
                        // Sino de Notificações
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_outlined,
                                color: LiquidTheme.textPrimary,
                                size: 24,
                              ),
                              onPressed: () =>
                                  _showNotificationsPanel(context, ref),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: LiquidTheme.warningPastel,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Foto de Perfil / Ações de Logout
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'logout') {
                              ref.read(authNotifierProvider.notifier).signOut();
                            }
                          },
                          offset: const Offset(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: LiquidTheme.textPrimary.withOpacity(0.08),
                            ),
                          ),
                          color: LiquidTheme.surface.withOpacity(0.95),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: LiquidTheme.secondary.withOpacity(
                              0.3,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: LiquidTheme.primary,
                              size: 20,
                            ),
                          ),
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.settings_outlined, size: 18),
                                  SizedBox(width: 10),
                                  Text("Minha Conta"),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout_outlined,
                                    size: 18,
                                    color: LiquidTheme.warningPastel,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Sair da Sessão",
                                    style: TextStyle(
                                      color: LiquidTheme.warningPastel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Efeito de Fundo: Aura Radiante Sutil
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: LiquidTheme.secondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 70.0), child: body),
        ],
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notifications",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        final list = ref.watch(notificationsProvider);

        return Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 80, right: 24),
              width: 320,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: LiquidTheme.glassDecoration(
                blurOpacity: 0.12,
                borderOpacity: 0.15,
                radius: 16,
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: LiquidTheme.glassBlur(),
                  child: Container(
                    color: LiquidTheme.surface.withOpacity(0.9),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Avisos e Notificações",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: LiquidTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10),
                        if (list.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Text(
                                "Nenhuma notificação.",
                                style: TextStyle(
                                  color: LiquidTheme.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final n = list[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    n.title,
                                    style: TextStyle(
                                      fontWeight: n.read
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 13,
                                      color: n.read
                                          ? LiquidTheme.textSecondary
                                          : LiquidTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    n.message,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: LiquidTheme.textSecondary,
                                    ),
                                  ),
                                  trailing: !n.read
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: LiquidTheme.primary,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  notificationsProvider
                                                      .notifier,
                                                )
                                                .markAsRead(n.id);
                                          },
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
