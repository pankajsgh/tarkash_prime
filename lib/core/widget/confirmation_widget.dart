

import 'package:flutter/material.dart';

class ConfirmationDialog {
  static const Color _danger = Color(0xFFDC2626);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMedium = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);


  static void show({
    required BuildContext context,
    String title = 'Are you sure?',
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Delete',
    IconData icon = Icons.delete_outline_rounded,
    bool isDestructive = true,
    required VoidCallback positiveClick,
    VoidCallback? negativeClick,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: 27,
                          color: isDestructive
                              ? _danger
                              : const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Please confirm your action',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          negativeClick?.call();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: _textMedium,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            negativeClick?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                            ),
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            positiveClick();
                          },
                          icon: Icon(icon, size: 17),
                          label: Text(confirmText),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: isDestructive
                                ? _danger
                                : const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
