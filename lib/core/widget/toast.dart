
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme/colors.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class Toast {
  static OverlayEntry? _currentToast;

  static void show({
    String? title,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('Overlay not found');
      return;
    }

    _currentToast?.remove();

    final config = _getToastConfig(type);

    final entry = OverlayEntry(
      builder: (_) => _AnimatedToast(
        title: title,
        message: message,
        icon: config.icon,
        color: config.color,
      ),
    );

    _currentToast = entry;

    overlayState.insert(entry);

    Future.delayed(duration, () {
      if (_currentToast == entry) {
        entry.remove();
        _currentToast = null;
      }
    });
  }

  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          color: Color(0xFF22C55E),
          icon: Icons.check_circle_rounded,
        );

      case ToastType.error:
        return _ToastConfig(
          color: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );

      case ToastType.warning:
        return _ToastConfig(
          color: Color(0xFFF59E0B),
          icon: Icons.warning_amber_rounded,
        );

      case ToastType.info:
        return _ToastConfig(
          color: Color(0xFF3B82F6),
          icon: Icons.info_rounded,
        );
    }
  }
}
class _ToastConfig {
  final Color color;
  final IconData icon;

  _ToastConfig({
    required this.color,
    required this.icon,
  });
}

class _AnimatedToast extends StatefulWidget {
  final String? title;
  final String message;
  final Color color;
  final IconData icon;

  const _AnimatedToast({
    super.key,
    this.title,
    required this.message,
    required this.color,
    required this.icon,
  });


  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with TickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: .85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 20,
                    sigmaY: 20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.72),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: primaryAppColor.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(.18),
                          blurRadius: 35,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [

                          // /// Glow Strip
                          // Container(
                          //   width: 2.5,
                          //   decoration: BoxDecoration(
                          //     color: widget.color,
                          //     borderRadius: BorderRadius.circular(100),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: widget.color.withOpacity(.5),
                          //         blurRadius: 10,
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          const SizedBox(width: 14),

                          /// Icon
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.color.withOpacity(.12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                if (widget.title != null &&
                                    widget.title!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      widget.title!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff111827),
                                      ),
                                    ),
                                  ),

                                Text(
                                  widget.message,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.25,
                                    color: Color(0xff374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}