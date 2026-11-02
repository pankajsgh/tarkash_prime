

import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppLoader {
  AppLoader._();

  static bool _isShowing = false;

  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color lightPrimary = Color(0xFFEFF6FF);
  static const Color pageBackground = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF64748B);

  static Future<void> showLoader(
      BuildContext context, {
        bool barrierDismissible = false,
        String? message,
      }) async {
    if (_isShowing || !context.mounted) return;

    _isShowing = true;

    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: barrierDismissible,
        barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.30),
        builder: (_) {
          return PopScope(
            canPop: barrierDismissible,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: AppLoadingCard(
                  message: message ?? 'Preparing your workspace...',
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isShowing = false;
    }
  }

  static void hideLoader(BuildContext context) {
    if (!_isShowing || !context.mounted) return;

    final navigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

class AppLoadingCard extends StatefulWidget {
  const AppLoadingCard({
    super.key,
    this.message = 'Preparing your workspace...',
  });

  final String message;

  @override
  State<AppLoadingCard> createState() => _AppLoadingCardState();
}

class _AppLoadingCardState extends State<AppLoadingCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _ringController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  static const Color _primary = AppLoader.primary;
  static const Color _lightPrimary = AppLoader.lightPrimary;
  static const Color _textDark = AppLoader.textDark;
  static const Color _textMedium = AppLoader.textMedium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppLoader.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 45,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: _primary.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoAnimation(),
          const SizedBox(height: 10),
          const Text(
            'WORKSPACE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: _textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we get things ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _textMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(),
          const SizedBox(height: 19),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: _textMedium.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              const Text(
                'Secure business operations',
                style: TextStyle(
                  fontSize: 11,
                  color: _textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAnimation() {
    return SizedBox(
      width: 190,
      height: 155,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _ringController,
        ]),
        builder: (context, child) {
          final pulse = Curves.easeInOut.transform(
            _pulseController.value,
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft blue glow.
              Container(
                width: 90 + pulse * 12,
                height: 90 + pulse * 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(
                        alpha: 0.08 + pulse * 0.08,
                      ),
                      blurRadius: 30 + pulse * 10,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Two subtle animated rings.
              _buildRing(
                _ringController.value,
              ),
              _buildRing(
                (_ringController.value + 0.5) % 1.0,
              ),

              // Your actual application logo.
              Transform.scale(
                scale: 0.96 + pulse * 0.05,
                child: Image.asset(
                  'assets/icons/icon_gobuzy.png',
                  width: 116,
                  height: 116,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.business_rounded,
                      size: 72,
                      color: _primary,
                    );
                  },
                ),
              ),

              // Floating business accent.
              Positioned(
                right: 32,
                top: 28,
                child: Transform.translate(
                  offset: Offset(0, -pulse * 3),
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppLoader.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withValues(alpha: 0.10),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: _primary,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing(double progress) {
    final scale = 0.72 + progress * 0.35;
    final opacity = ((1 - progress) * 0.30).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 100 * scale,
        height: 100 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 5,
            width: double.infinity,
            color: _lightPrimary,
            child: Align(
              alignment: Alignment(
                -1 + (_shimmerController.value * 2),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.34,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF93C5FD),
                        _primary,
                        AppLoader.primaryDark,
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

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({
    super.key,
    this.message = 'Preparing your workspace...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppLoader.pageBackground,
      body: Center(
        child: AppLoadingCard(
          message: message,
        ),
      ),
    );
  }
}