import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

class Toast {
  Toast._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void success(String message) =>
      show(message: message, type: ToastType.success, title: 'Success');

  static void error(String message) =>
      show(message: message, type: ToastType.error, title: 'Error');

  static void warning(String message) =>
      show(message: message, type: ToastType.warning, title: 'Warning');

  static void info(String message) =>
      show(message: message, type: ToastType.info, title: 'Info');

  static void show({
    required String message,
    ToastType type = ToastType.info,
    String? title,
  }) {
    final overlay = navigatorKey.currentState?.overlay;

    if (overlay == null) {
      debugPrint('Toast: Navigator overlay is not ready.');
      return;
    }

    _timer?.cancel();
    _entry?.remove();
    _entry = null;

    final color = switch (type) {
      ToastType.success => const Color(0xFF16A34A),
      ToastType.error => const Color(0xFFDC2626),
      ToastType.warning => const Color(0xFFD97706),
      ToastType.info => const Color(0xFF2563EB),
    };

    final backgroundColor = switch (type) {
      ToastType.success => const Color(0xFFDCFCE7),
      ToastType.error => const Color(0xFFFEE2E2),
      ToastType.warning => const Color(0xFFFEF3C7),
      ToastType.info => const Color(0xFFDBEAFE),
    };

    final icon = switch (type) {
      ToastType.success => Icons.check_circle,
      ToastType.error => Icons.error,
      ToastType.warning => Icons.warning,
      ToastType.info => Icons.info,
    };

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        title: title,
        color: color,
        backgroundColor: backgroundColor,
        icon: icon,
        onClose: () => _remove(entry),
      ),
    );

    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(
      const Duration(seconds: 3),
          () => _remove(entry),
    );
  }

  static void _remove(OverlayEntry entry) {
    if (entry.mounted) entry.remove();

    if (identical(_entry, entry)) {
      _entry = null;
      _timer?.cancel();
      _timer = null;
    }
  }

  static void dismiss() {
    final entry = _entry;
    if (entry != null) _remove(entry);
  }
}

class _ToastView extends StatelessWidget {
  final String message;
  final String? title;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onClose;

  const _ToastView({
    required this.message,
    required this.title,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Material(
        color: backgroundColor,
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
