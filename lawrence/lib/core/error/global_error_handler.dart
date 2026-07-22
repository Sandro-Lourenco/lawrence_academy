import 'package:flutter/material.dart';
import '../../design_system/widgets/state_widgets.dart';
import 'app_error.dart';

class GlobalErrorHandler {
  static Widget buildErrorWidget(dynamic error, [VoidCallback? onRetry]) {
    final appError = AppError.fromException(error);

    if (appError.type == ErrorType.network) {
      return AppOfflineState(
        title: appError.title,
        message: appError.message,
        onRetry: onRetry,
      );
    }

    return AppErrorState(
      title: appError.title,
      message: appError.message,
      onRetry: onRetry,
    );
  }

  static void showSnackBar(BuildContext context, dynamic error) {
    final appError = AppError.fromException(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(appError.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(appError.message)),
          ],
        ),
        backgroundColor: appError.type == ErrorType.network
            ? Colors.orange
            : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
