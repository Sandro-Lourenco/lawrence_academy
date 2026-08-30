import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/student_profile_controller.dart';

/// A single reactive avatar source for navigation, menus and learning chrome.
class StudentAvatar extends ConsumerWidget {
  const StudentAvatar({super.key, this.radius = 22});

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider).valueOrNull;
    final avatarUrl = profile?.avatarUrl?.trim();
    final initials = profileInitials(profile?.fullName, profile?.email ?? '');
    final diameter = radius * 2;
    return Semantics(
      image: true,
      label: 'Foto de perfil de ${profile?.fullName ?? 'aluno'}',
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _AvatarFallback(initials: initials),
              )
            : _AvatarFallback(initials: initials),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}
