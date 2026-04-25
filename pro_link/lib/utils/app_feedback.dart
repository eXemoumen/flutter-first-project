import 'package:flutter/material.dart';

class AppFeedback {
  const AppFeedback._();

  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF1F7A1F),
    );
  }

  static void info(BuildContext context, String message) {
    _show(context, message);
  }

  static void error(
    BuildContext context,
    Object error, {
    String fallbackMessage = 'Something went wrong. Please try again.',
  }) {
    final text = _cleanError(error);
    _show(
      context,
      text.isEmpty ? fallbackMessage : text,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static String _cleanError(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.substring('Exception:'.length).trim();
    }
    if (raw.startsWith('PostgrestException(') && raw.endsWith(')')) {
      return raw.substring('PostgrestException('.length, raw.length - 1).trim();
    }
    return raw;
  }
}

